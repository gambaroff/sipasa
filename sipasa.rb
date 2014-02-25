require 'sinatra'


get '/ranges' do
  Ip.all.to_json
  format_response :json
  '{
    "webservers":"192.168.2.0/24",
    "dbs":["192.168.5.2", "192.168.5.10"]
  }'
end

get '/range/:id' do
  Ip.where(:id =>params['id']).first.to_json
end

get '/range/$range/(stephaniascomputer)' do
  '192.168.2.3'
end

# new host 

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
