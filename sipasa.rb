require 'sinatra'
require_relative 'ip_addr'
require_relative 'file_store'

# check file exists, otherwise create it with 

# world = { ranges: [], used: [] }

get '/pools' do
  #format_response :json
  @json_file = JsonStore.new
  @pools, @interfaces, @ips, @hosts = GraphFactory.new.read(@json_file.retrieve())
  ranges = {}
  @pools.each do |name, pool|
    ranges[name] = pool.range
  end
  ranges.to_json
end

put '/pools/:pool' do
  poolname = params['pool']
  input = JSON.parse(request.body.read)
  @json_file = JsonStore.new
  @pools, @interfaces, @ips, @hosts = GraphFactory.new.read(@json_file.retrieve())
  before = @pools.to_json
  @pools[poolname] = Pool.new(poolname, input['range'])
  @json_file.store(@pools)
  status 201
end

get '/pools/:pool' do
  @json_file = JsonStore.new
  @pools, @interfaces, @ips, @hosts = GraphFactory.new.read(@json_file.retrieve())
  poolname = params['pool']
  pool = @pools[poolname]
  interfaces = pool.interfaces.map{|name, value| name}
  pool.interfaces = interfaces
  pool.to_json
end

get '/interfaces' do
  @json_file = JsonStore.new
  @pools, @interfaces, @ips, @hosts = GraphFactory.new.read(@json_file.retrieve())
  ip_entry = params['interface']
  interfaces = @interfaces.map { |name, value| name }.to_json 
end

get '/interfaces/:interface' do
  @json_file = JsonStore.new
  @pools, @interfaces, @ips, @hosts = GraphFactory.new.read(@json_file.retrieve())
  ip_entry = params['interface']
  @interfaces[ip_entry].to_json
end

put '/pools/:pool/:interface' do
  poolname = params['pool']
  interfacename = params['interface']
  input = JSON.parse(request.body.read)
  @json_file = JsonStore.new
  @pools, @interfaces, @ips, @hosts = GraphFactory.new.read(@json_file.retrieve())
  interface, is_new = @pools[poolname].provision(interfacename, input["mac"], input["type"], input["host"])
  if is_new
    @json_file.store(@pools)
    status 201
  else
    status 200
  end
  interface.to_json
end

get '/ips' do
  @json_file = JsonStore.new
  @pools, @interfaces, @ips, @hosts = GraphFactory.new.read(@json_file.retrieve())
  @ips.map{|name, value|name}.to_json
end

get '/ips/:ip' do
  @json_file = JsonStore.new
  @pools, @interfaces, @ips, @hosts = GraphFactory.new.read(@json_file.retrieve())
  ipaddr = params['ip']
  ip = @ips[ipaddr]
  interfaces = ip.interfaces.map do |name, value|
    name
  end
  hosts = ip.hosts.map do |name, value|
    name
  end
  ip.interfaces = interfaces
  ip.hosts = hosts
  ip.to_json
end
