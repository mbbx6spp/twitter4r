require('rake/gempackagetask')

meta = Twitter::Meta.new(ROOT_DIR)
namespace :package do
  desc "Create Gem Packages"
  Rake::GemPackageTask.new(meta.gem_spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
end

namespace :gemspec do
  desc "Create GemSpec"
  task :generate do
    spec = meta.pkg_info['spec']
    rgs = ERB.new(File.read(File.join(ROOT_DIR, 'config', 'templates', 'github.gemspec.erb')), 0)
    s = rgs.result(spec.send(:binding))
    gs_file = File.join(ROOT_DIR, 'twitter4r.gemspec')
    File.delete(gs_file) if File.exist?(gs_file)
    File.open(gs_file, 'w') {|f| f.write(s); }
  end
end
