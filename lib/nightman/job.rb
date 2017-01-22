module Nightman
  class Job
    SANITY = 604800
    def initialize(options={})
      @name           = options[:name]
      @path           = options[:path]
      @clean_after    = options[:clean_after].to_i
      @dry_run        = options[:dry_run] == false ? false : true
      @include_match = options[:include_match] || ['.']
      @exclude_match = options[:exclude_match] || []
      @start_time     = Time.now.to_i
      @dry_run        = true unless sane?
      setup_match_rules
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
    attr_reader :include_match
    attr_reader :exclude_match

  private
    # if any include match rules, only delete include matches
    # if any exclude match rules, never delete exclude matches
    # if both, exclude matches override include matches
    def setup_match_rules
      include_match << Regexp.new('.') if @include_match.flatten.size == 0
      $logger.debug "include match rules:"
      @include_match.each { |pm| $logger.debug "+ #{pm.to_s}" }
      $logger.debug "exclude match rules:"
      @exclude_match.each { |nm| $logger.debug "+ #{nm.to_s}" }
    end

    def match_rules(name)
      include = @include_match.any? { |pm| name.match(pm) }
      exclude = @exclude_match.any? { |nm| name.match(nm) }
      decision = no_rules? || ( include && !exclude )
      $logger.debug "#{name}: no_rules=#{no_rules?}, include=#{include}, exclude=#{exclude}, decision=#{decision}"
      decision
    end

    def no_rules?
      @include_match.size == 0 && @exclude_match.size == 0
    end

    def process_one(filename)
      begin
        stat = File::Stat.new(filename)
        return unless stat.file?
        age = start_time - stat.mtime.to_i
        if age > clean_after && match_rules(filename)
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
