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
    @range = ip_addr_range.is_a?(String) ? IPAddr.new(ip_addr_range).to_range : IPAddr.new(ip_addr_range[0])..IPAddr.new(ip_addr_range[1])
  end
  def to_json(*a)
    {
      'pools'   => {'first' => { 'range' => '192.168.2.0/24', 
        'interfaces' => {'cheddarcheese.example.com' => {
          'ip_addr' => '192.168.2.3',
          'mac' => '12:34:56:78:92',
          'type' => 'primary',
          'host' => Host.name,
          'requested' => 'Tue Feb 25 14:57:35 PST 2014'   
          },
          'cheddarcheese.example.com-logical' => {
          'ip_addr' => '192.168.2.4',
          'mac' => '12:34:56:78:92',
          'type' => 'logical',
          'host' => Host.name,
          'requested' => 'Tue Feb 25 14:57:35 PST 2014'
           },
          'cheddarcheese.example.com-dsr' =>{
          'ip_addr' => '192.168.2.4',
          'mac' => '12:34:56:78:93',
          'type' => 'direct-return-interface-group',
          'host' => Host.name,
          'requested' => 'Tue Feb 25 14:57:35 PST 2014 ' 
          }}}}
    }.to_json(*a)  
  end
end

class IP
  attr_accessor :hosts, :interfaces
  def initialize(ipaddr)
    @ipaddr = IPAddr.new(ipaddr)
    @hosts = {}
    @interfaces = {}
  end
end

class Host
  attr_accessor :name, :ips, :interfaces
  def initialize(hostname)
    @name = hostname
    @ips = {}
    @interfaces = {} 
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
    @pools = resource['pools'].collect do |poolname, poolentries|
      pool = Pool.new(poolname, poolentries['range'])
      poolentries['interfaces'].each do |interface, entry|
        ip_addr=entry['ip_addr']
        ip = @ips[ip_addr]
        if ip == nil
          ip =  IP.new(ip_addr)
          @ips[ip_addr] = ip
        end
        hostname = entry['host']
        if hostname != nil
          host = @hosts[hostname]
          if host == nil
            host =  Host.new(hostname)
            @hosts[hostname] = host
          end
        end
        #do something with IP
        if @interfaces[interface] != nil
          raise "duplicate interfaces exist"
        end
        @interfaces[interface] = Interface.new(interface, ip, entry['mac'], entry['type'], host, entry['requested_time'])
      end
      pool
    end
    return @pools, @interfaces, @ips, @hosts
  end

end