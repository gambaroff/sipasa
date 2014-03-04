require_relative("../rest_interface")
require 'test/unit'
require 'rack/test'
require 'delorean'

class TestRestInterfaces <  Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end


=begin
 List pools:
curl -XGET http://127.0.0.1:9292/pools

Show a pool:
curl -XGET http://127.0.0.1:9292/pools/first

Add a pool:
curl -XPUT http://127.0.0.1:9292/pools/second -d @poolcreate.json
or stdin:
curl -XPUT http://127.0.0.1:9292/pools/second -d @-
{"range": "10.10.0.0/24"}
<Ctl-D>

Show interfaces:
curl -XGET http://127.0.0.1:9292/interfaces

Show an interface:
curl -XGET http://127.0.0.1:9292/interfaces/cheddarcheese.example.com

Create an interface:
curl -XPUT http://127.0.0.1:9292/pools/second/mahchegocheese.example.com -d @-
{"mac":"12:34:56:78:99","type":"primary","host":"manchegocheese"}
^D

Show IPs:
curl -XGET http://127.0.0.1:9292/ips

Show an IP:
curl -XGET http://127.0.0.1:9292/ips/192.168.2.4


Show hosts:
curl -XGET http://127.0.0.1:9292/hosts

Show an interface:
curl -XGET http://127.0.0.1:9292/interfaces/manchegocheese
 
=end

  def setup
    File.delete("ipworld.json") if File.exists?("ipworld.json")
  end
  
  def test_pool_starts_empty
    # TODO figure out test fixtures so we don't delete our database while running tests... use a testing datafile instead
    get '/pools'
    assert_equal '{}', last_response.body
  end

  def test_pool_creation
    put '/pools/corp_private', '{"range": "10.10.10.0/24"}'
    response = last_response
    assert_equal '', last_response.body
    assert_equal 201, last_response.status
  end
  
  def test_pool_retrieval
    put '/pools/corp_private', '{"range": "10.10.10.0/24"}'
    get '/pools/corp_private'
    assert_equal '{"range":"10.10.10.0/24","interfaces":[]}', last_response.body
    assert_equal 200, last_response.status
  end
  
  def test_pools_cannot_overlap
    put '/pools/corp_private', '{"range": "10.10.10.0/24"}'
    get '/pools/corp_private'
    assert_equal 200, last_response.status
    put '/pools/corp_alternate', '{"range": ["10.10.10.10", "10.10.10.20"]}'
    assert_equal 409, last_response.status
  end

  def test_interface_creation
    put '/pools/corp_private', '{"range": "10.10.10.0/24"}'
    Delorean.time_travel_to '2014-03-02 21:03:27 -0800'
    put '/pools/corp_private/manchegocheese-primary', '{"mac":"12:34:56:78:99","type":"primary","host":"manchegocheese"}'
    assert_equal '{"ip_addr":"10.10.10.0","mac":"12:34:56:78:99","type":"primary","requested":"2014-03-02 21:03:27 -0800","host":"manchegocheese"}', last_response.body
    assert_equal 201, last_response.status
  end
  
  def test_pools_can_be_immutable
    put '/pools/corp_immutable', '{"range": "10.10.5.0/24", "immutable": true}'
    get '/pools/corp_immutable'
    assert_equal 200, last_response.status
    assert_equal '{"range":"10.10.5.0/24","interfaces":[],"immutable":true}', last_response.body
    put '/pools/corp_immutable/manchegocheese-primary', '{"mac":"12:34:56:78:99","type":"primary","host":"manchegocheese"}'
    assert_equal 409, last_response.status
    # nice to have: assert_equal '{"error":"pool corp_immutable is immutable"}', last_response.body
  end

  def test_pools_can_specify_subnet_gateway
    put '/pools/corp_private', '{"range": ["10.10.10.2", "10.10.10.6"], "netmask": "255.255.255.0", "gateway": "10.10.10.1"}'
    Delorean.time_travel_to '2014-03-02 21:03:27 -0800'
    put '/pools/corp_private/manchegocheese-primary', '{"mac":"12:34:56:78:99","type":"primary","host":"manchegocheese"}'
    assert_equal '{"ip_addr":"10.10.10.2","mac":"12:34:56:78:99","type":"primary","requested":"2014-03-02 21:03:27 -0800","host":"manchegocheese","gateway":"10.10.10.1","netmask":"255.255.255.0"}', last_response.body
    assert_equal 201, last_response.status
  end
  
  def test_interface_retrieval
    put '/pools/corp_private', '{"range": "10.10.10.0/24"}'
    Delorean.time_travel_to '2014-03-02 21:03:27 -0800'
    put '/pools/corp_private/manchegocheese-primary', '{"mac":"12:34:56:78:99","type":"primary","host":"manchegocheese"}'
    get '/interfaces'
    assert_equal '["manchegocheese-primary"]', last_response.body
    assert_equal 200, last_response.status
    get '/interfaces/manchegocheese-primary'
    assert_equal '{"ip_addr":"10.10.10.0","mac":"12:34:56:78:99","type":"primary","requested":"2014-03-02 21:03:27 -0800","host":"manchegocheese"}', last_response.body
    assert_equal 200, last_response.status
  end
  
  def test_ips_generated
    put '/pools/corp_private', '{"range": "10.10.10.0/24"}'
    Delorean.time_travel_to '2014-03-02 21:03:27 -0800'
    put '/pools/corp_private/manchegocheese-primary', '{"mac":"12:34:56:78:99","type":"primary","host":"manchegocheese"}'
    put '/pools/corp_private/swisscheese-primary', '{"mac":"12:34:56:78:95","type":"primary","host":"swisscheese"}'
    put '/pools/corp_private/manchegocheese-vhost-www.example.com', '{"mac":"12:34:56:78:94","type":"vhost","host":"manchegocheese"}'
    get '/ips'
    assert_equal '["10.10.10.0","10.10.10.1","10.10.10.2"]', last_response.body
    assert_equal 200, last_response.status
    get '/ips/10.10.10.0'
    assert_equal '{"hosts":["manchegocheese"],"interfaces":["manchegocheese-primary"]}', last_response.body
    assert_equal 200, last_response.status
    get '/ips/10.10.10.1'
    assert_equal '{"hosts":["swisscheese"],"interfaces":["swisscheese-primary"]}', last_response.body
    assert_equal 200, last_response.status
    get '/ips/10.10.10.2'
    assert_equal '{"hosts":["manchegocheese"],"interfaces":["manchegocheese-vhost-www.example.com"]}', last_response.body
    assert_equal 200, last_response.status
  end
  
  def test_hosts_generated
    put '/pools/corp_private', '{"range": "10.10.10.0/24"}'
    Delorean.time_travel_to '2014-03-02 21:03:27 -0800'
    put '/pools/corp_private/manchegocheese-primary', '{"mac":"12:34:56:78:99","type":"primary","host":"manchegocheese"}'
    put '/pools/corp_private/swisscheese-primary', '{"mac":"12:34:56:78:95","type":"primary","host":"swisscheese"}'
    put '/pools/corp_private/manchegocheese-vhost-www.example.com', '{"mac":"12:34:56:78:94","type":"vhost","host":"manchegocheese"}'
    get '/hosts'
    assert_equal '["manchegocheese","swisscheese"]', last_response.body
    assert_equal 200, last_response.status
    get '/hosts/manchegocheese'
    assert_equal '{"ips":["10.10.10.0","10.10.10.2"],"interfaces":["manchegocheese-primary","manchegocheese-vhost-www.example.com"]}', last_response.body
    assert_equal 200, last_response.status
    get '/hosts/swisscheese'
    assert_equal '{"ips":["10.10.10.1"],"interfaces":["swisscheese-primary"]}', last_response.body
    assert_equal 200, last_response.status
  end
  
end