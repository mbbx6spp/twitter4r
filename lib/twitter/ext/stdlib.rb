# Contains Ruby standard library extensions specific to <tt>Twitter4R</tt> library.

# Extension to Hash to create URL encoded string from key-values
class Hash
  # Returns string formatted for HTTP URL encoded name-value pairs.
  # For example,
  #  {:id => 'thomas_hardy'}.to_http_str 
  #  # => "id=thomas_hardy"
  #  {:id => 23423, :since => Time.now}.to_http_str
  #  # => "since=Thu,%2021%20Jun%202007%2012:10:05%20-0500&id=23423"
  def to_http_str
    result = ''
    return result if self.empty?
    self.each do |key, val|
      result << "#{key}=#{CGI.escape(val.to_s)}&"
    end
    result.chop # remove the last '&' character, since it can be discarded
  end
end

# Extension to Time that outputs RFC2822 compliant string on #to_s
class Time
  alias :old_to_s :to_s
  
  # Returns RFC2822 compliant string for <tt>Time</tt> object.
  # For example,
  #  # Tony Blair's last day in office (hopefully)
  #  best_day_ever = Time.local(2007, 6, 27)
  #  best_day_ever.to_s # => "Wed, 27 Jun 2007 00:00:00 +0100"
  # You can also pass in an option <tt>format</tt> argument that 
  # corresponds to acceptable values according to ActiveSupport's 
  # +Time#to_formatted_s+ method.
  def to_s(format = nil)
    format ? self.to_formatted_s(format) : self.rfc2822
  end
end

# Extension to Kernel to add #gem_present? without any exceptions raised
module Kernel

  # Returns whether or not a gem exists without raising a Gem::LoadError exception
  def gem_present?(gem_name, version = nil)
    present = false
    begin
      present = !!(version ? gem(gem_name, version) : gem(gem_name))
    rescue Gem::LoadError => le
      present = false
      warn("Gem load error: Couldn't load #{gem_name} #{version ? "with version requirement #{version}: #{le.to_s}": ""}")
    end
    present
  end
end
