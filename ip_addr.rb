require 'json'
require 'ipaddr'

class IPGenerator
  #todo
  def initialize()
  end
end

class Pool
  attr_reader :name, :range
  attr_accessor :interfaces, :notes
  def initialize(name, ip_addr_range)
    @name = name
    @range_text = ip_addr_range
    @range = ip_addr_range.is_a?(String) ? IPAddr.new(ip_addr_range).to_range : IPAddr.new(ip_addr_range[0])..IPAddr.new(ip_addr_range[1])
    @interfaces = {}
    @notes = ""
  end
  def to_json(*a)
     {
      'range' => @range_text,
      'interfaces' => @interfaces
    }.to_json(*a)
  end
end

class IP
  attr_accessor :ipaddr, :hosts, :interfaces
  def initialize(ipaddr)
    @ipaddr = IPAddr.new(ipaddr)
    @hosts = {}
    @interfaces = {}
  end
  def to_json(*a)
    {
      'hosts' => @hosts,
      'interfaces' => @interfaces
    }.to_json(*a)
  end

end

class Host
  attr_accessor :name, :ips, :interfaces
  def initialize(hostname)
    @name = hostname
    @ips = {}
    @interfaces = {} 
  end
  def to_json(*a)
    {
      'ips' => @ips,
      'interfaces' => @interfaces
    }.to_json(*a)
  end
end


class Interface
  attr_reader :name, :ip, :mac, :type, :host, :requested_time
  def initialize(name, ip, mac, type, host, requested_time)
    @name, @ip, @mac, @type, @host, @requested_time = name, ip, mac, type, host, requested_time
  end
  def to_json(*a)
    hash = {
      'ip_addr' => @ip.ipaddr.to_s,
      'mac' => @mac,
      'type' => @type,
      'requested' => @requested_time
    }
    hash['host'] = @host.name if @host != nil
    hash.to_json(*a)
  end
end


class GraphFactory 
  def read(json)
    resource = JSON.parse(json)
    @interfaces = {}
    @ips = {}  
    @hosts = {}
    @pools = {} 
    resource.each do |poolname, poolentries|
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
          host.ips[ip_addr] = ip
        end
        #do something with IP
        if @interfaces[interface] != nil
          raise "duplicate interfaces exist"
        end
        iface = Interface.new(interface, ip, entry['mac'], entry['type'], host, entry['requested'])
        @interfaces[interface] = iface
        ip.interfaces[interface] = iface
        ip.hosts[hostname] = host
      end
      pool.interfaces = @interfaces
      @pools[poolname] = pool
    end
    return @pools, @interfaces, @ips, @hosts
  end
  

end