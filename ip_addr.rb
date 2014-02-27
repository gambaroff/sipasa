require 'json'
require 'ipaddr'

class IPGenerator
  #todo
  def initialize()
  end
end

class Pool
  attr_reader :name, :range
  attr_accessor :interfaces, :notes, :ips
  def initialize(name, ip_addr_range)
    @name = name
    @range_text = ip_addr_range
    @range = ip_addr_range.is_a?(String) ? IPAddr.new(ip_addr_range).to_range : IPAddr.new(ip_addr_range[0])..IPAddr.new(ip_addr_range[1])
    @interfaces = {}
    @ips = {}
    @notes = ""
  end
  def provision(name, mac, type, hostname, requested_time=Time.new)
    interface = @interfaces[name]
    if(interface != nil)
      return interface, false
    end
    ipaddr=first_available.to_s
    ip=IP.new(ipaddr)
    host=Host.new(hostname)
    interface = Interface.new(name, ip, mac, type, requested_time, host=host)
    @ips[ipaddr] = ip
    @interfaces[name] = interface
    return interface, true
  end
  def to_json(*a)
     {
      'range' => @range_text,
      'interfaces' => @interfaces
    }.to_json(*a)
  end
  def first_available
    for ip in @range
      if @ips[ip.to_s] == nil
        return ip
      end
    end
    return nil
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
  def initialize(name, ip, mac, type, requested_time, host=nil)
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
    @all_interfaces = {}
    @all_ips = {}  
    @hosts = {}
    @pools = {} 
    resource.each do |poolname, poolentries|
      @interfaces = {}
      @ips = {}
      #todo Pool json parsing so we do more in constructors and/or methods
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
        if @all_interfaces[interface] != nil
          raise "duplicate interfaces exist"
        end
        iface = Interface.new(interface, ip, entry['mac'], entry['type'], entry['requested'], host)
        @interfaces[interface] = iface
        @all_interfaces[interface] = iface
        ip.interfaces[interface] = iface
        ip.hosts[hostname] = host
      end
      pool.interfaces = @interfaces
      pool.ips = @ips

      @pools[poolname] = pool
    end
    return @pools, @interfaces, @ips, @hosts
  end
  

end