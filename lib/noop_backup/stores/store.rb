module NoopBackup::Stores
  class Store
    private

    def config
      @config ||= NoopBackup.config
    end
  end
end
