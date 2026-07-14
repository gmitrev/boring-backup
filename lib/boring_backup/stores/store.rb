module BoringBackup::Stores
  class Store
    def name
      self.class.name.split("::").last.downcase
    end

    def description
      name
    end

    private

    def config
      @config ||= BoringBackup.config
    end
  end
end
