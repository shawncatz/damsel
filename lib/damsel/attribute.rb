module Damsel
  class Attribute
    attr_reader :name, :type, :default, :klass, :block

    def initialize(name, options={})
      o = {
          child: false,
          default: nil,
          type: String,
          klass: nil,
          many: false,
          named: false,
          block: nil,
      }.merge(options)
      @name = name.to_sym
      @child = o[:child]
      @default = o[:default]
      @named = o[:named]
      @many = o[:many]
      @klass = o[:klass]
      @type = o[:type]
      @block = o[:block]

      if type == Array
        @default = []
      elsif type == :child
        if many?
          @default = []
        else
          @default = {}
        end
      end
    end

    def child?
      @child
    end

    def many?
      @many
    end

    def named?
      @named
    end
  end
end
