module Damsel
  class AttributeSet
    attr_reader :attrs

    def initialize
      @attrs = {}
    end

    def <<(attribute)
      @attrs[attribute.name] = attribute
    end

    def [](name)
      return @attrs[name] if @attrs[name]
      singular = name.to_s.singularize.to_sym
      return @attrs[singular] if @attrs[singular]
      plural = name.to_s.pluralize.to_sym
      return @attrs[plural] if @attrs[plural]
      raise "unknown attribute: #{name} (#{singular} #{plural})"
    end
  end
end
