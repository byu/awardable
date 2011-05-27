module Awardable
  module VERSION
    MAJOR = 0
    MINOR = 1
    PATCH = 0
    BUILD = 'alpha'

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
  end
end
