require_relative "noop_backup/version"
require_relative "noop_backup/configuration"
require_relative "noop_backup/tee"
require_relative "noop_backup/utils"
require_relative "noop_backup/stores"
require_relative "noop_backup/commands/backup"
require_relative "noop_backup/notifiers/slack"
require_relative "noop_backup/notifiers/stdout"

module NoopBackup
  class Error < StandardError; end

  class DumpTooSmallError < Error; end
  class DumpFailedError < Error; end
  class ConfigurationError < Error; end

  class BackupFailedError < Error
    attr_reader :result

    def initialize(result)
      @result = result

      super("Backup failed (#{result.status}): #{result.error&.message || failed_stores(result)}")
    end

    private

    def failed_stores(result)
      result.store_results.reject(&:success).map(&:store).join(", ")
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias_method :config, :configuration

    def reset!
      @configuration = nil
    end

    def configure
      yield(configuration)
    end

    # Attempt to boot host app. Booting it should trigger the configuration process.
    def prepare!
      env_file = File.expand_path("config/environment.rb")

      require env_file if File.exist?(env_file)
    end

    def notify(message)
      config.notifiers.each do |notifier|
        notifier.notify(message)
      end
    end

    def utils
      NoopBackup::Utils
    end
  end
end

require_relative "noop_backup/plugins/rails" if defined? Rails::Railtie
