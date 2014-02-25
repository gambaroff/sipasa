require 'json'
require 'ipaddr'

#ip_range = IPAddr.new("192.168.2.0")..IPAddr.new("192.168.2.6")

world = { ranges: [], used: [] }
class IPGenerator
  def initialize(world)
    @range = world.each{

    }
    @used
  end
end

class IpPool
  def initialize(ip_addr_range, dhcp, dns_settings, proxy_server, network_associations)
    @range = ip_addr_range
  end
end

class IpResource
  attr_reader :ip_ranges
  def initialize(json)
    ranges = JSON.parse(json)
    @ip_ranges = ranges.collect do |range|
      range.is_a?(String) ? IPAddr.new(range).to_range : IPAddr.new(range[0])..IPAddr.new(range[1])
    end
  end

end