module NoopBackup
  class BackupJob < ActiveJob::Base
    queue_as :default

    def perform
      result = NoopBackup::Commands::Backup.execute

      raise NoopBackup::BackupFailedError.new(result) unless result.success?
    end
  end
end
