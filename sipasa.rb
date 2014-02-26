require 'sinatra'
require_relative 'ip_addr'
require_relative 'file_store'

# check file exists, otherwise create it with 

# world = { ranges: [], used: [] }
@json_file = JsonStore.new
@pools, @interfaces, @ips, @hosts = GraphFactory.new.read(@json_file.retrieve())

get '/pools' do
  format_response :json
  @pools.to_json
end

get '/pools/:id' do
  poolname = params['id']
  @pools[poolname].to_json
end

get '/range/:range/:ip_entry' do
  range = param['range']
  ip_entry = param['ip_entry']
  resource.lookup(ip)
end


# new host 
post '/range/:range/:ip_entry' do
  resource = IpResource.new()
  range = param['range']
  ip_entry = param['ip_entry']
  if resource.exists?(ip_entry)
    entry = resource.lookup(ip) 
  else
    entry = IP.new(ip)
  end
end


get '/range/$range/(newhost)' do
  #return empty - not found
   json_status 404, "Not found"
end

post '/ranges/$range/newhost' do
  #find next free ip and put in data structure
end

get '/range/$range/(newhost)' do
  #now there is an address so return that as JSON
end
