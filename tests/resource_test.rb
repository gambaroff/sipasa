require 'test/unit'

require_relative("../ip_addr")

class TestResource <  Test::Unit::TestCase
  
  def test_range_creation
    input = '{
      "first":{
        "range":"192.168.2.0/24", 
        "interfaces":{}
      },
      "second":{
        "range": ["192.168.3.2", "192.168.3.9"], 
        "interfaces":{}
       }
     }'
    factory = GraphFactory.new
    pools, interfaces, ips, hosts = factory.read(input)
    first = pools['first']
    second = pools['second']
    assert_equal Pool, first.class 
    assert_equal Range, first.range.class 
    assert_equal Range, second.range.class
    assert_equal IPAddr.new("192.168.2.0"), first.range.first
    assert_equal IPAddr.new("192.168.2.255"), first.range.last
    assert_equal IPAddr.new("192.168.3.2"), second.range.first
    assert_equal IPAddr.new("192.168.3.9"), second.range.last
  end
  
  def test_entry_creation
    input = '{
        "first":{
          "range": "192.168.2.0/24", 
          "interfaces": {
            "creamcheese.example.com": {
              "ip_addr": "192.168.2.1", 
              "mac": "12:34:56:78:90",
              "type": "primary",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            }, 
            "bluecheese.example.com": {
              "ip_addr": "192.168.2.2", 
              "mac": "12:34:56:78:91",
              "type": "logical",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            }
          }}}'
    factory = GraphFactory.new
    pools, interfaces, ips, hosts = factory.read(input)
    assert_equal JSON.parse(input), JSON.parse(pools.to_json)
    #puts sut.ip_addresses #should have 192.168.2.1, 192.168.2.2
  end
  
  def test_host_creation
    input = '{
        "first":{
          "range": "192.168.2.0/24", 
          "interfaces": {
            "cheddarcheese.example.com": {
              "ip_addr" : "192.168.2.3", 
              "mac": "12:34:56:78:92",
              "type": "primary",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            },
            "cheddarcheese.example.com-logical": {
              "ip_addr": "192.168.2.4", 
              "mac": "12:34:56:78:92",
              "type": "logical",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            },
            "cheddarcheese.example.com-dsr": {
              "ip_addr" : "192.168.2.4", 
              "mac": "12:34:56:78:93",
              "type": "direct-return-interface-group",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            }
          }}}'
    factory = GraphFactory.new
    pools, interfaces, ips, hosts = factory.read(input)
    assert_equal JSON.parse(input), JSON.parse(pools.to_json)
    assert_equal 1, hosts.length
    assert_equal "cheddarcheese", hosts.keys[0]
  end
  
  
  def test_pool_contains_hosts_interfaces_for_itself
    input = '{
        "first":{
          "range": "192.168.2.0/24", 
          "interfaces": {
            "cheddarcheese.example.com": {
              "ip_addr" : "192.168.2.3", 
              "mac": "12:34:56:78:92",
              "type": "primary",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            }
          }},
        "second":{
          "range": "192.168.3.0/24", 
          "interfaces": {
            "cheddarcheese.example.com-logical": {
              "ip_addr": "192.168.3.4",
              "mac": "12:34:56:78:92",
              "type": "logical",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            }
          }}
    }'
    factory = GraphFactory.new
    pools, interfaces, ips, hosts = factory.read(input)
    assert_equal 1, pools['first'].interfaces.length
    assert_equal 1, pools['second'].interfaces.length
  end
  
  def test_adding_interface
   input = '{
        "first":{
          "range": ["192.168.2.3", "192.168.2.9"],
          "interfaces": {
            "cheddarcheese.example.com": {
              "ip_addr" : "192.168.2.3",
              "mac": "12:34:56:78:92",
              "type": "primary",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            },
            "cheddarcheese.example.com-logical": {
              "ip_addr": "192.168.2.4", 
              "mac": "12:34:56:78:92",
              "type": "logical",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            },
            "cheddarcheese.example.com-dsr": {
              "ip_addr" : "192.168.2.4", 
              "mac": "12:34:56:78:93",
              "type": "direct-return-interface-group",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            }
          }}}'
    factory = GraphFactory.new
    pools, interfaces, ips, hosts = factory.read(input)
    assert_equal 2, ips.length
    interfacename = "manchegocheese.example.com"
    poolname = "first"
    interfacecreate = '{"mac":"12:34:56:78:99","type":"primary","host":"manchegocheese"}'
    params = JSON.parse(interfacecreate)
    pools[poolname].provision(interfacename, params["mac"], params["type"], params["host"], requested_time="Thu Feb 27 09:27:25 PST 2014")
    expected = '{
        "first":{
          "range": ["192.168.2.3", "192.168.2.9"], 
          "interfaces": {
            "cheddarcheese.example.com": {
              "ip_addr" : "192.168.2.3", 
              "mac": "12:34:56:78:92",
              "type": "primary",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            },
            "cheddarcheese.example.com-logical": {
              "ip_addr": "192.168.2.4", 
              "mac": "12:34:56:78:92",
              "type": "logical",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            },
            "cheddarcheese.example.com-dsr": {
              "ip_addr" : "192.168.2.4", 
              "mac": "12:34:56:78:93",
              "type": "direct-return-interface-group",
              "host": "cheddarcheese",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            },
            "manchegocheese.example.com": {
              "ip_addr" : "192.168.2.5", 
              "mac": "12:34:56:78:99",
              "type": "primary",
              "host": "manchegocheese",
              "requested": "Thu Feb 27 09:27:25 PST 2014"
            }
          }}}'
    assert_equal JSON.parse(expected), JSON.parse(pools.to_json)
    #TODO make this work assert_equal 3, ips.length
  end
  
  def test_pool_starting_ip
    pool = Pool.new("dummy", ["192.168.2.3", "192.168.2.9"])
    assert_equal "192.168.2.3", pool.first_available.to_s
  end
  
  def test_pool_skips_existing
    pool = Pool.new("dummy", ["192.168.2.3", "192.168.2.9"])
    first="192.168.2.3"
    pool.ips[first] = IP.new(first)
    assert_equal "192.168.2.4", pool.first_available.to_s
  end
  
  def test_pool_full
    pool = Pool.new("dummy", ["192.168.2.3", "192.168.2.5"])
    first="192.168.2.3"
    pool.ips[first] = IP.new(first)
    second="192.168.2.4"
    pool.ips[second] = IP.new(second)
    third="192.168.2.5"
    pool.ips[third] = IP.new(third)
    assert_equal nil, pool.first_available
  end

  def test_pool_interface_exists
    input = '{
      "first":{
        "range":"192.168.2.0/24", 
        "interfaces":{
           "creamcheese.example.com": {
              "ip_addr": "192.168.2.1", 
              "mac": "12:34:56:78:90",
              "type": "primary",
              "requested": "Tue Feb 25 14:57:35 PST 2014"
            }
          }
      }}'
    factory = GraphFactory.new
    pools, interfaces, ips, hosts = factory.read(input)
    poolname = "first"
    interfacename = "creamcheese.example.com"
    interfacecreate = '{"mac":"12:34:56:78:99","type":"primary","host":"manchegocheese"}'
    params = JSON.parse(interfacecreate)
    interface_created, is_new = pools[poolname].provision(interfacename, params["mac"], params["type"], params["host"], requested_time="Thu Feb 27 09:27:25 PST 2014")
    assert_equal false, is_new
    assert_equal "192.168.2.1", interface_created.ip.ipaddr.to_s
    #don't update anything. this will likely change in the future to make it more rest-y.
    assert_equal JSON.parse(input), JSON.parse(pools.to_json)
  end
  
end
