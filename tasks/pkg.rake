require('rake/gempackagetask')

meta = Twitter::Meta.new(File.join(File.dirname(__FILE__), '..'))
namespace :package do
  desc "Create Gem Packages"
  Rake::GemPackageTask.new(meta.gem_spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
end
