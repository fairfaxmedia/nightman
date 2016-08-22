require 'nightman/job'
require 'yaml'

module Nightman
  class Config
    def initialize(config_file)
      begin
        yaml = YAML.load_file(config_file)
      rescue Exception => e
        $logger.error "unable to load config file: #{config_file}: #{e.class}/#{e.message}"
        exit 1
      end
      @jobs = yaml.keys.map do |job|
        begin
          obj = Job.new({
            :name        => job,
            :path        => yaml[job]['path'],
            :clean_after => yaml[job]['clean_after'],
            :dry_run     => yaml[job]['dry_run'] || true
          })
        rescue
          $logger.warn "#{job}: configuration errors found"
        end
        obj
      end
    end
    def run!
      @jobs.keep_if { |x| x }.each do |job|
        job.execute!
      end
    end
  end
end
