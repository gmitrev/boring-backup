module NoopBackup
  class BackupJob < ActiveJob::Base
    queue_as :default

    def perform
      NoopBackup::Commands::Backup.execute
    end
  end
end
