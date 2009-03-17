require('metric_fu')

MetricFu::Configuration.run do |config|
  config.metrics  = [:coverage, :flog, :flay, :reek, :roodi, :churn]
#  config.coverage = { :test_files => "spec/**/*_spec.rb" }
  config.flog     = { :dirs_to_flog => ['lib']  }
  config.saikuro  = { "--warn_cyclo" => "3", "--error_cyclo" => "4" }
end

