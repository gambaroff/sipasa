require 'test/unit'

require_relative("../ip_addr")

class TestResource <  Test::Unit::TestCase
  
  def test_range_creation
    @input = '{
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
    output, @interfaces, @ips, @hosts = factory.read(@input)
    first = output['first']
    second = output['second']
    assert_equal Pool, first.class #fails cuase it is currently a String
    assert_equal Range, first.range.class #fails cause it is caurrently an Array
    assert_equal Range, second.range.class #fails cause it is caurrently an Array
    assert_equal IPAddr.new("192.168.2.0"), first.range.first
    assert_equal IPAddr.new("192.168.2.255"), first.range.last
    assert_equal IPAddr.new("192.168.3.2"), second.range.first
    assert_equal IPAddr.new("192.168.3.9"), second.range.last
  end
  
  def test_entry_creation
    @input = '{
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
    @pools, @interfaces, @ips, @hosts = factory.read(@input)
    assert_equal JSON.parse(@input), JSON.parse(@pools.to_json)
    #puts sut.ip_addresses #should have 192.168.2.1, 192.168.2.2
  end
  
  def test_host_creation
    @input = '{
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
    @pools, @interfaces, @ips, @hosts = factory.read(@input)
    assert_equal JSON.parse(@input), JSON.parse(@pools.to_json)
    #todo, fill in what this should return.  then do the same for interfaces
    # assert_equal ["cheddar"], @ips["192.168.2.4"].hosts 
  end
end
