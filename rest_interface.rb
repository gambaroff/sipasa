require 'sinatra'
require_relative 'ip_addr'
require_relative 'file_store'

get '/pools' do
  #format_response :json
  json_file = JsonStore.new
  pools = GraphFactory.new.read(json_file.retrieve())
  ranges = {}
  pools.each do |name, pool|
    ranges[name] = pool.range
  end
  ranges.to_json
end

put '/pools/:pool' do
  poolname = params['pool']
  input = JSON.parse(request.body.read)
  json_file = JsonStore.new
  pools = GraphFactory.new.read(json_file.retrieve())
  range = input['range']
  options = {
    immutable: input['immutable'],
    netmask: input['netmask'],
    gateway: input['gateway']
  }
  pools.each do |poolname_it, pool|
    if (pool.range.first <= range.last) && (range.first <= pool.range.last)
      status 409
      return
    end
  end
  pools[poolname] = Pool.new(poolname, range, options)
  json_file.store(pools)
  status 201
end

get '/pools/:pool' do
  json_file = JsonStore.new
  pools = GraphFactory.new.read(json_file.retrieve())
  poolname = params['pool']
  pool = pools[poolname]
  pool.interfaces = pool.interfaces.keys
  pool.to_json
end

get '/interfaces' do
  json_file = JsonStore.new
  pools = GraphFactory.new.read(json_file.retrieve())
  interfaces = pools.collect {|_,pool| pool.interfaces.keys}.flatten
  interfaces.to_json 
end

get '/interfaces/:interface' do
  json_file = JsonStore.new
  pools = GraphFactory.new.read(json_file.retrieve())
  if_entry = params['interface']
  interfaces = pools.collect{|_,pool| pool.interfaces.fetch(if_entry)}
  if interfaces.empty?
    status 404
  else
    interface = interfaces[0]
    interface.to_json
  end
end

put '/pools/:pool/:interface' do
  poolname = params['pool']
  interfacename = params['interface']
  input = JSON.parse(request.body.read)
  json_file = JsonStore.new
  pools = GraphFactory.new.read(json_file.retrieve())
  pool = pools[poolname]
  interface, is_new = pool.provision(interfacename, input["mac"], input["type"], input["host"])
  if is_new
    json_file.store(pools)
    status 201
  else
    status 200
  end
  if interface
    interface.gateway = pool.gateway if pool.gateway
    interface.netmask = pool.netmask if pool.netmask
    interface.to_json
  else
    status 409
  end
end

get '/ips' do
  json_file = JsonStore.new
  pools = GraphFactory.new.read(json_file.retrieve())
  ips = pools.collect {|_,pool| pool.ips.keys}.flatten
  ips.to_json
end

get '/ips/:ip' do
  json_file = JsonStore.new
  pools = GraphFactory.new.read(json_file.retrieve())
  ipaddr = params['ip']
  ips = pools.collect{|_,pool| pool.ips.fetch(ipaddr)}
  if ips.empty?
    status 404
  else
    ip = ips[0]
    ip.interfaces = ip.interfaces.keys
    ip.hosts = ip.hosts.keys
    ip.to_json
  end
end


get '/hosts' do
  json_file = JsonStore.new
  pools = GraphFactory.new.read(json_file.retrieve())
  filter = Proc.new{|_,interface| interface.host.name}
  hosts = pools.collect {|_,pool| pool.interfaces.collect(&filter)}.flatten.uniq
  hosts.to_json
end

get '/hosts/:host' do
  json_file = JsonStore.new
  pools = GraphFactory.new.read(json_file.retrieve())
  hostname = params['host']
  hosts = pools.collect {|_,pool| pool.find_host(hostname)}
  if hosts.empty?
    status 404
  else
    host = hosts[0]
    host.interfaces = host.interfaces.keys
    host.ips = host.ips.keys
    host.to_json
  end
end
