module Damsel
  class Exec < Base
    def intialize
      @id = false
    end

    def save(block)
      @id = block.object_id
      Damsel::Exec.save(@id, &block)
    end

    def to_hash
      {
          id: @id,
      }
    end

    class << self
      def save(id, &block)
        @blocks ||= {}
        @blocks[id] = block
      end

      def get(id)
        @blocks[id]
      end
    end
  end
end
