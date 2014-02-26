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

class Pool
  attr_reader :name, :range
  def initialize(name, ip_addr_range)
    @name = name
    @range = range.is_a?(String) ? IPAddr.new(range).to_range : IPAddr.new(range[0])..IPAddr.new(range[1])
  end
end

class IP
  attr_accessor :hosts, :interfaces
  def initialize(ipaddr)
    @ipaddr = IPAddr.new(ipaddr)
    @hosts = []
    @interfaces = []
  end
end

class Host
  attr_accessor :name, :ips, :interfaces
  def initialize(hostname)
    @name = hostname
    @ips = []
    @interfaces = [] 
  end
end


class Interface
  attr_reader :name, :ip, :mac, :type, :host, :requested_time
  def initialize(name, ip, mac, type, host, requested_time)
    @name, @ip, @mac, @type, @host, @requested_time = name, ip, mac, type, host, requested_time
  end
end


class GraphFactory 
  def read(json)
    resource = JSON.parse(json)
    @interfaces = {}
    @ips = {}  
    @hosts = {}
    @pools = resource['pools'].collect do |poolname, pool|
      pool = Pool.new(poolname, pool['range'])
      pool['interfaces'].each do |interface, entry|
        ip_addr=entry['ip_addr']
        if @ips.contains?(ip_addr) 
          ip = @ips[ip_addr]
        else
          ip =  IP.new(ip_addr)
          @ips[ip_addr] = ip
        end
        hostname = entry['host']
        if hostname != nil
          if @hosts.contains?(hostname) 
            host = @hosts[hostname]
          else
            host =  Host.new(hostname)
            @hosts[hostname] = host
          end
        end
        #do something with IP
        if @interfaces.contains?(interface)
          raise "duplicate interfaces exist"
        end
        @interfaces[interface] = Interface.new(interface, ip, entry['mac'], entry['type'], host, entry['requested_time'])
      end
      pool
    end
    return @pools, @interfaces, @ips, @hosts
  end

end