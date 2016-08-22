module Nightman
  class Job
    SANITY = 604800
    def initialize(options={})
      @name        = options[:name]
      @path        = options[:path]
      @clean_after = options[:clean_after].to_i
      @dry_run     = options[:dry_run]
      @start_time  = Time.now.to_i
      @dry_run     = true unless sane?
    end

    def sane?
      sane = true
      if clean_after < SANITY
        $logger.error "#{name}: silly clean_after setting, must be >#{SANITY}: #{clean_after}"
        sane = false
      end
      if ! Dir.exists?(path)
        $logger.error "#{name}: non-existent path: #{path}"
        sane = false
      end
      $logger.error "#{name}: bogus settings, forcing dry run" unless sane
      sane
    end

    def execute!
      $logger.info "#{name}: starting (dry_run=#{dry_run ? "yes" : "no"})"
      begin
        Dir.chdir(path) do
          $logger.debug "#{name}: entered #{path}"
          Dir.foreach('.') do |fn|
            process_one(fn)
          end
        end
      rescue Exception => e
        $logger.error "#{name}: error encountered: #{e.class}/#{e.message}"
      end
    end

    attr_reader :name
    attr_reader :path
    attr_reader :clean_after
    attr_reader :start_time
    attr_reader :dry_run
  private
    def process_one(filename)
      begin
        stat = File::Stat.new(filename)
        return unless stat.file?
        age = start_time - stat.mtime.to_i
        if age > clean_after
          verbiage = dry_run ? "Would delete" : "Delete"
          $logger.info "#{verbiage}: #{filename}"
          File.delete(filename) unless dry_run
        end
      rescue Exception => e
        $logger.warn "#{name}: error encountered handling #{filename}: #{e.class}/#{e.message}"
      end
    end
  end
end
