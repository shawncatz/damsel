module Damsel
  class Base
    def initialize
      @data = Marshal.load(Marshal.dump(self.class.attrs))
    end

    def method_missing(method, *args, &block)
      m = method.to_sym
      #puts "method_missing: #{m} #{args.inspect}"
      raise "#{self.class.name}: unknown attribute #{method}: #{@data.inspect}" unless @data[m]
      o = @data[m]

      if o[:type] == Array
        #puts "setting #{m} << #{args.first}"
        o[:value] << args.first
      elsif o[:type] == :child
        #puts "setting child #{m} << #{o[:klass]} #{args.first}"

        k = o[:klass].constantize
        obj = k.new
        obj.name(args.first) if args.count > 0

        if obj.is_a?(Damsel::Data)
          obj.instance_eval &block if block_given?
        elsif obj.is_a?(Damsel::Exec)
          obj.block block
          obj.save block
        end

        if o[:many]
          if o[:named]
            o[:value] ||= {}
            a = args.first.to_sym
            raise "setting more than one #{method}[#{a}]: previous: #{o[:value][a]}" if o[:value][a]
            o[:value][a] = obj
          else
            o[:value] << obj
          end
        else
          raise "setting more than one #{method}: previous: #{o[:value].inspect}" if o[:value]
          o[:value] = obj
        end
      else
        #puts "setting #{m} = #{args.first}"
        o[:value] = args.first
      end
    end

    def validate!
      if @data[:block]
        #block.call(self)
      end
    rescue => e
      raise "validation failed: #{e.message} at #{e.backtrace.first}"
    end

    def to_hash
      @hash ||= begin
        out = {}
        @data.each do |k, v|
          val = v[:value]
          if val.is_a?(Array)
            out[k] = []
            val.each do |e|
              out[k] << (e.respond_to?(:to_hash) ? e.to_hash : e)
            end
          elsif val.is_a?(Hash)
            out[k] = {}
            val.each do |vk, e|
              out[k][vk] = (e.respond_to?(:to_hash) ? e.to_hash : e)
            end
          else
            out[k] = val.respond_to?(:to_hash) ? val.to_hash : val
          end
        end
        out
      end
    end

    #def to_mash
    #  Hashie::Mash.new(to_hash)
    #end

    class << self
      @attrs = {}
      attr_accessor :attrs
      attr_accessor :search_module

      def attribute(name, options={}, &block)
        n = name.to_sym
        o = {
            value: nil,
            type: :string,
            klass: nil
        }.merge(options)
        #puts "ATTR: #{name} - #{o.inspect}"

        if o[:type] == Array
          n = name.to_s.singularize.to_sym
          o[:value] = [] unless o[:value]
        else
          if o[:type] == :child
            if o[:many]
              if o[:named]
                o[:value] = {} unless o[:value]
              else
                o[:value] = [] unless o[:value]
              end
            else
              o[:value] = nil
            end
          end

        end

        o[:block] = block if block_given?

        @attrs ||= {}
        @attrs[n] = o
      end

      def has_one(name, options={})
        o = {
            klass: find_class(name),
            type: :child,
            many: false,
            named: false,
            value: nil
        }.merge(options)
        attribute(name, o)
      end

      def has_many(names, options={})
        singular = names.to_s.singularize
        o = {
            klass: find_class(singular),
            type: :child,
            many: true,
            named: false,
            value: nil
        }.merge(options)
        attribute(singular, o)
      end

      def references(name, options={})
        attribute(name, options)
      end

      def find_module(name)
        @module ||= begin
          list = name.split('::')
          list.pop
          list.join('::')
        end
      end

      def find_class(name)
        c = "#{find_module(self.name)}::#{name.capitalize}"
        #puts "FINDCLASS: #{name} #{c}"
        c
      rescue => e
        raise "could not find class: #{c}: #{e.message} at #{e.backtrace.first}"
      end
    end
  end
end
