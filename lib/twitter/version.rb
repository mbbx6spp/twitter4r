# version.rb contains <tt>Twitter::Version</tt> that provides helper
# methods related to versioning of the <tt>Twitter4R</tt> project.

module Twitter::Version #:nodoc:
  MAJOR = 0
  MINOR = 4
  REVISION = 0
  class << self
    # Returns X.Y.Z formatted version string
    def to_version
      "#{MAJOR}.#{MINOR}.#{REVISION}"
    end
    
    # Returns X-Y-Z formatted version name
    def to_name
      "#{MAJOR}_#{MINOR}_#{REVISION}"
    end
  end
end
