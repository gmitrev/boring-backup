require "test_helper"

module BoringBackup
  class Notifiers::SentinelTest < Minitest::Test
    def test_ping_url_keeps_full_urls
      assert_equal("http://example.com/ping/abc", ping_url("http://example.com"))
      assert_equal("https://example.com/ping/abc", ping_url("https://example.com"))
    end

    def test_ping_url_defaults_bare_hosts_to_https
      assert_equal("https://example.com/ping/abc", ping_url("example.com"))
    end

    def test_ping_url_uses_http_for_local_hosts
      assert_equal("http://localhost:3000/ping/abc", ping_url("localhost:3000"))
      assert_equal("http://127.0.0.1:3000/ping/abc", ping_url("127.0.0.1:3000"))
      assert_equal("http://0.0.0.0:8080/ping/abc", ping_url("0.0.0.0:8080"))
    end

    private

    def ping_url(host)
      BoringBackup::Notifiers::Sentinel.new(key: "abc", host: host).ping_url.to_s
    end
  end
end
