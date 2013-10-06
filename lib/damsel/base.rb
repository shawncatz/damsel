require "damsel/attribute_set"
require "damsel/attribute"

module Damsel
  class Base
    def initialize(name)
      @name = name
      @data = {}
      @names = []
    end

    def attrs
      self.class.attrs
    end

    def [](name)
      @data[name.to_sym]
    end

    def validate!
      if @data[:block]
        #block.call(self)
      end
    rescue => e
      raise "validation failed: #{e.message} at #{e.backtrace.first}"
    end

    def data
      raise "not used"
    end

    def to_hash
      recursive_hash(@data)
    end

    private

    def recursive_hash(value)
      if value.is_a?(Damsel::Base)
        #puts "BASE:#{value.inspect}"
        value.to_hash
      elsif value.is_a?(Hash)
        #puts "HASH:#{value.inspect}"
        out = {}
        value.each do |k, v|
          out[k] = recursive_hash(v)
        end
        out
      elsif value.is_a?(Array)
        #puts "ARRAY:#{value.inspect}"
        out = []
        value.each do |e|
          #puts "ARRAY:#{e}:"
          out << recursive_hash(e)
        end
        out
      else
        value
      end
    end

    class << self
      @attrs = {}
      attr_accessor :attrs
      attr_accessor :search_module

      def attribute(name, options={}, &block)
        name = name.to_sym
        options = {
            value: nil,
            type: :string,
            klass: nil
        }.merge(options)
        #puts "ATTR: #{name} - #{o.inspect}"

        name = name.to_s.singularize.to_sym if options[:type] == Array
        options[:block] = block if block_given?

        @attrs ||= Damsel::AttributeSet.new
        @attrs << Damsel::Attribute.new(name, options)

        define_method name, ->(value=nil, &b) do
          attr = attrs[name]
          @data[name] ||= attr.default ? attr.default.dup : nil

          if attr.block
            valid = attr.block.call(value)
            raise "validation for #{name} failed: #{attr.block}" unless valid
          end

          if attr.type == Array
            @data[name] << value
          elsif attr.type == :child
            k = attr.klass.constantize
            obj = k.new(name)
            obj.name value if value

            if attr.many?
              if attr.named?
                value = value.to_sym
                raise "setting more than one #{name}[#{value}]: previous: #{@data[name]}" if @names.include?("#{name}#{value}")
                @names << "#{name}#{value}"
                @data[name] << obj
              else
                @data[name] << obj
              end
            else
              raise "setting more than one #{name}: previous: #{@data[name].inspect}" if @data[name].count > 0
              @data[name] = obj
            end

            if obj.is_a?(Damsel::Data)
              obj.instance_eval &b if b
            elsif obj.is_a?(Damsel::Exec)
              obj.save b
            end
          else
            @data[name] = value
          end
        end
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
