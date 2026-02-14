# frozen_string_literal: true

require 'webrick'
require 'json'

class MockGitHubAPI
  attr_reader :port, :release_requests

  def initialize
    @port = find_available_port
    @release_requests = []
    @server = nil
  end

  def start
    @server = WEBrick::HTTPServer.new(Port: @port, Logger: WEBrick::Log.new('/dev/null'), AccessLog: [])

    @server.mount_proc('/repos/test-owner/test-repo/commits/abc123/pulls') do |_req, res|
      res['Content-Type'] = 'application/json'
      res.body = JSON.generate([{ number: 1 }])
    end

    @server.mount_proc('/repos/test-owner/test-repo/issues/1/labels') do |_req, res|
      res['Content-Type'] = 'application/json'
      res.body = JSON.generate(@labels)
    end

    @server.mount_proc('/repos/test-owner/test-repo/releases') do |req, res|
      @release_requests << JSON.parse(req.body)
      res['Content-Type'] = 'application/json'
      res.body = JSON.generate({
                                 html_url: 'https://github.com/test-owner/test-repo/releases/tag/mock-release'
                               })
    end

    @thread = Thread.new { @server.start }
  end

  def stop
    @server&.shutdown
    @thread&.join(5)
  end

  def labels=(labels)
    @labels = labels.map { |name| { name: name } }
  end

  private

  def find_available_port
    server = TCPServer.new('0.0.0.0', 0)
    port = server.addr[1]
    server.close
    port
  end
end
