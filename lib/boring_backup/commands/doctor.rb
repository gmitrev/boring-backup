module BoringBackup::Commands
  Check = Struct.new(:name, :status, :detail, keyword_init: true) do
    def failed? = status == :fail
    def ok? = status == :ok
  end

  DoctorResult = Struct.new(:checks, keyword_init: true) do
    def success? = checks.none?(&:failed?)

    def failures = checks.select(&:failed?)
  end

  class Doctor
    SOLID_QUEUE_SCHEDULE_FILE = "config/recurring.yml"
    SIDEKIQ_CRON_SCHEDULE_FILE = "config/schedule.yml"
    def self.execute = new.execute

    def execute
      checks = [
        pg_dump_present,
        pg_dump_version,
        database_resolved,
        stores_registered,
        *config.stores.flat_map { |store| store_checks(store) },
        *scheduler_checks
      ]

      DoctorResult.new(checks: checks.compact)
    end

    private

    def check(name, status, detail = nil)
      Check.new(name: name, status: status, detail: detail)
    end

    def pg_dump_present
      if pg_dump_path
        check("pg_dump", :ok, pg_dump_path)
      else
        check("pg_dump", :fail, "not found on PATH")
      end
    end

    def pg_dump_path
      return @pg_dump_path if defined?(@pg_dump_path)

      @pg_dump_path = ENV.fetch("PATH", "").split(File::PATH_SEPARATOR)
        .map { |dir| File.join(dir, "pg_dump") }
        .find { |path| File.executable?(path) }
    end

    def pg_dump_version
      return unless pg_dump_path

      client = major_version(`#{pg_dump_path} --version`)
      server = major_version(server_version)

      return check("versions", :skip, "could not read server version") unless server
      return check("versions", :skip, "could not read pg_dump version") unless client

      if client >= server
        check("versions", :ok, "pg_dump #{client}, server #{server}")
      else
        check("versions", :fail, "pg_dump #{client} is older than server #{server} — the dump may not restore")
      end
    end

    def major_version(string)
      string.to_s[/(\d+)/, 1]&.to_i
    end

    def server_version
      return unless defined?(::ActiveRecord)

      ::ActiveRecord::Base.connection.select_value("SHOW server_version")
    rescue
      nil
    end

    def database_resolved
      database = config.pg_env["PGDATABASE"]

      if database.to_s.empty?
        check("database", :fail, "could not resolve PGDATABASE")
      else
        check("database", :ok, database)
      end
    end

    def stores_registered
      if config.stores.empty?
        check("stores", :fail, "no stores registered")
      else
        check("stores", :ok, "#{config.stores.size} registered")
      end
    end

    def store_checks(store)
      store.validate!

      [check(store.name, :ok, store.description)]
    rescue => e
      [check(store.name, :fail, e.message)]
    end

    def scheduler_checks
      checks = [solid_queue_check, sidekiq_cron_check].compact

      if checks.none?(&:ok?)
        [check("scheduler detected", :skip, "no schedulers detected. Make sure BackupJob is executed in a cron or within a scheduler.")]
      else
        checks.select(&:ok?)
      end
    end

    def solid_queue_check
      if File.exist?(SOLID_QUEUE_SCHEDULE_FILE) && File.read(SOLID_QUEUE_SCHEDULE_FILE, mode: "r:UTF-8").include?("BoringBackup::BackupJob")
        check("scheduler detected", :ok, "solid-queue: #{SOLID_QUEUE_SCHEDULE_FILE}")
      end
    end

    def sidekiq_cron_check
      if File.exist?(SIDEKIQ_CRON_SCHEDULE_FILE) && File.read(SIDEKIQ_CRON_SCHEDULE_FILE, mode: "r:UTF-8").include?("BoringBackup::BackupJob")
        check("scheduler detected", :ok, "sidekiq-cron: #{SIDEKIQ_CRON_SCHEDULE_FILE}")
      end
    end

    def config
      @config ||= BoringBackup.config
    end
  end
end
