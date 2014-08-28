# encoding: utf-8

require 'bundler'
Bundler.require

require 'socket'

class Net::HTTP::Persistent
  alias_method :connection_for_origin, :connection_for
  attr_accessor :local_host
  attr_accessor :local_port
  def connection_for uri
    conn = connection_for_origin uri
    if conn.local_host != @local_host || conn.local_port != @local_port
      conn.local_host = @local_host
      conn.local_port = @local_port
      conn.finish
    end
    conn
  end
end

class Mechanize
  def bind(local_host = nil, local_port = nil)
    @agent.http.local_host = local_host
    @agent.http.local_port = local_port
  end
end


def test address = nil
  $a ||= Mechanize.new
  $a.bind address if address
  res = $a.get 'http://wtfismyip.com/text'
  res.body.strip
end

local_addresses = Socket.getifaddrs.select{|_|
  _.addr.ipv4?
}.select{|_|
  /(?:eth|en)\d+(?::\d+)?/ =~ _.name
}

puts 'Try: default'
puts 'Got: ' + test
puts '-' * 20

local_addresses.each do |_|
  puts "Try: #{_.addr.ip_address}(#{_.name})"
  puts 'Got: ' + test(_.addr.ip_address)
  puts '-' * 20
end

