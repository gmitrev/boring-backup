require "thor"

module Noop::Backup
  class CLI < Thor
    def self.exit_on_failure? = true

    desc "backup", "Create and store a new backup"
    def backup
      Noop::Backup.prepare!
      Noop::Backup::Commands::Backup.execute
    end
  end
end
