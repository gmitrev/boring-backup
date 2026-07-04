require "test_helper"

module NoopBackup
  class Commands::BackupTest < Minitest::Test
    def setup
      NoopBackup.reset!
    end

    def test_single_store_streams_full_dump
      sink = StringIO.new
      fake_store = NoopBackup::Stores::FakeStore.new(sink:)
      fake_store.key = "test-123"

      NoopBackup.configure do |config|
        config.pg_database = "test-123"
        config.stores << fake_store
      end

      text = "Look at my horse, my horse is amazing"
      command = generate_shell_command(output: text)

      # TODO: Find a way to disable the report implicitly, maybe a flag when running tests
      # or only output when in terminal, not in scripts
      result = NoopBackup::Commands::Backup.execute(command:, report: false)

      assert result.success?
      assert_equal(sink.string, text)
    end

    def test_two_stores_stream_full_dump
      sink_a = StringIO.new
      sink_b = StringIO.new
      store_a = NoopBackup::Stores::FakeStore.new(sink: sink_a)
      store_b = NoopBackup::Stores::FakeStore.new(sink: sink_b)
      store_a.key = store_b.key = "test-123"

      NoopBackup.configure do |config|
        config.pg_database = "test-123"
        config.stores << store_a << store_b
      end

      text = "Look at my horse, my horse is amazing"
      command = generate_shell_command(output: text)

      result = NoopBackup::Commands::Backup.execute(command:, report: false)

      assert result.success?
      assert_equal(text, sink_a.string)
      assert_equal(text, sink_b.string)
      assert_equal(2, result.store_results.size)
      assert result.store_results.all?(&:success)
    end

    private

    def generate_shell_command(output:, exit_code: 0)
      [
        RbConfig.ruby,
        "-e",
        "STDOUT.binmode; STDOUT.write(#{output.inspect}); exit(#{exit_code})"
      ]
    end
  end
end
