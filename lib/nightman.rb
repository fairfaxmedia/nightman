require 'nightman/config'
require 'nightman/version'
require 'thor'
require 'logger'

module Nightman
  $logger = Logger.new(STDOUT)
  class CLI < Thor
    method_option :config,
      type: :string, required: true,
      desc: 'path to configuration file'
    desc :cleanup, 'starts cleanup job'
    def cleanup
      $logger.debug "configuring from file: #{options[:config]}"
      config = Config.new(options[:config])
      config.run!
    end

    desc :version, 'displays app version'
    def version
      puts "Nightman #{VERSION}"
    end
  end
end
