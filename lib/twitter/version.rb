module Twitter::Version #:nodoc:
  MAJOR = 0
  MINOR = 1
  REVISION = 1
  class << self
    def to_version
      "#{MAJOR}.#{MINOR}.#{REVISION}"
    end
    
    def to_name
      "#{MAJOR}_#{MINOR}_#{REVISION}"
    end
  end
end
