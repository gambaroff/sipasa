require 'json'
require 'ipaddr'

class Pool
  attr_reader :name, :range, :netmask, :gateway
  attr_accessor :interfaces, :notes, :ips, :immutable
  def initialize(name, ip_addr_range, options)
    @name = name
    @range_text = ip_addr_range
    @range = ip_addr_range.is_a?(String) ? IPAddr.new(ip_addr_range).to_range : IPAddr.new(ip_addr_range[0])..IPAddr.new(ip_addr_range[1])
    @interfaces = {}
    @ips = {}
    @notes = ""
    @immutable = options[:immutable]
    @netmask = options[:netmask]
    @gateway = options[:gateway]
  end

  def provision(name, mac, type, hostname, requested_time=Time.now)
    return nil, false if @immutable
    interface = @interfaces[name]
    return interface, false if interface
    ipaddr=first_available.to_s
    ip = IP.new(ipaddr)
    host = Host.new(hostname)
    interface = Interface.new(name, ip, mac, type, requested_time, host = host)
    @ips[ipaddr] = ip
    @interfaces[name] = interface
    return interface, true
  end

  def to_json(*a)
    output = {
      'range' => @range_text,
      'interfaces' => @interfaces
    }
    output['immutable'] = true if @immutable
    output['netmask'] = @netmask if @netmask
    output['gateway'] = @gateway if @gateway
    output.to_json(*a)
  end

  def first_available
    for ip in @range
      if @ips[ip.to_s] == nil
      return ip
      end
    end
    return nil
  end
  
  def find_host(hostname)
    @interfaces.each do |_,interface|
      return interface.host if interface.host.name == hostname
    end
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
    output = {
      'ips' => @ips.collect{|ipaddr, ip| ipaddr},
      'interfaces' => @interfaces.collect{|ifname, interface| ifname}
    }
    output.to_json(*a)
  end
end

class Interface
  attr_reader :name, :ip, :mac, :type, :host, :requested_time
  attr_accessor :gateway, :netmask
  def initialize(name, ip, mac, type, requested_time, host=nil)
    @name, @ip, @mac, @type, @host, @requested_time = name, ip, mac, type, host, requested_time
    @gateway = nil
    @netmask = nil
  end

  def to_json(*a)
    hash = {
      'ip_addr' => @ip.ipaddr.to_s,
      'mac' => @mac,
      'type' => @type,
      'requested' => @requested_time
    }
    hash['host'] = @host.name if @host
    hash['gateway'] = @gateway if @gateway
    hash['netmask'] = @netmask if @netmask
    hash.to_json(*a)
  end
end

class GraphFactory
  def read(json)
    resource = JSON.parse(json)
    all_interfaces = {}
    all_ips = {}
    hosts = {}
    pools = {}
    resource.each do |poolname, poolentries|
      interfaces = {}
      ips = {}
      #todo Pool json parsing so we do more in constructors and/or methods
      options = {
        immutable: poolentries['immutable'],
        netmask: poolentries['netmask'],
        gateway: poolentries['gateway']        
      }
      pool = Pool.new(poolname, poolentries['range'], options)
      poolentries['interfaces'].each do |interface, entry|
        ip_addr=entry['ip_addr']
        ip = ips[ip_addr]
        unless ip
          ip =  IP.new(ip_addr)
          ips[ip_addr] = ip
        end
        hostname = entry['host']
        if hostname
          host = hosts[hostname]
         unless host
            host =  Host.new(hostname) unless host
            hosts[hostname] = host
          end
          host.ips[ip_addr] = ip
        end
        # do something with IP
        if all_interfaces[interface]
          raise "duplicate interfaces exist"
        end
        iface = Interface.new(interface, ip, entry['mac'], entry['type'], entry['requested'], host)
        interfaces[interface] = iface
        all_interfaces[interface] = iface
        ip.interfaces[interface] = iface
        ip.hosts[hostname] = host
        if hostname
          hosts[hostname].interfaces[interface] = iface
        end
      end
      pool.interfaces = interfaces
      pool.ips = ips
      all_ips.merge!(ips)
      pools[poolname] = pool
    end
    return pools
  end

end