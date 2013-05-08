unless defined?(Damsel::Version)
  module Damsel
    module Version
      MAJOR = 0
      MINOR = 1
      TINY = 0
      TAG = nil
      STRING = [MAJOR, MINOR, TINY, TAG].compact.join(".")
    end
  end
end
