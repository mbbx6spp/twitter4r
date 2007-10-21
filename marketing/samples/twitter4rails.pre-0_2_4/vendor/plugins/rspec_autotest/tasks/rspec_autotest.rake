# (c) Copyright 2006-2007 Nick Sieger <nicksieger@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

namespace :spec do
  desc "Start Autotest"
  task :autotest do
    require File.join(File.dirname(__FILE__), '..', 'lib', 'rspec_autotest')
    if File.directory? File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'vendor')
      RspecOnRailsAutotest.run
    else
      RspecAutotest.run
    end
  end
  
  namespace :autotest do
    desc "Start Autotest on Rails"
    task :rails do
      require File.join(File.dirname(__FILE__), '..', 'lib', 'rspec_autotest')
      RspecOnRailsAutotest.run
    end
  end
end