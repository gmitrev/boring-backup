module Noop::Backup::Notifiers
  class Stdout
    def notify(text)
      puts text
    end
  end
end
