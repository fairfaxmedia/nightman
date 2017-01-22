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
          y = yaml[job]
          obj = Job.new({
            :name           => job,
            :path           => y['path'],
            :clean_after    => y['clean_after'],
            :dry_run        => ( y.include?('dry_run') && y['dry_run'] == false ) ? false : true,
            :include_match => [y['include_match'] || []].flatten.map { |pm| Regexp.new(pm) },
            :exclude_match => [y['exclude_match'] || []].flatten.map { |nm| Regexp.new(nm) },
          })
          # using flatten here means yaml list merging *should* work.
          # Untested!
          # good for complicated configs.
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
