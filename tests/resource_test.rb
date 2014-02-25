require 'test/unit'

require_relative("../ip_addr")

class TestResource <  Test::Unit::TestCase
  
  def test_range_creation
    @ranges = '{"ranges": ["192.168.2.0/24", ["192.168.3.2", "192.168.3.9"]], "entries":[]}'
    sut = IpResource.new(@ranges)
    output = sut.ip_ranges
    assert_equal Range, output[0].class #fails cuase it is currently a String
    assert_equal Range, output[1].class #Fails cause it is caurrently an Array
    assert_equal IPAddr.new("192.168.2.0"), output[0].first
    assert_equal IPAddr.new("192.168.2.255"), output[0].last
    assert_equal IPAddr.new("192.168.3.2"), output[1].first
    assert_equal IPAddr.new("192.168.3.9"), output[1].last
  end
  
  def test_entry_creation
    @input = '{
      "ranges": ["192.168.2.0/24"], 
      "entries": [
        "creamcheese.example.com":{
          "ip_addr" : "192.168.2.1", 
          "mac": 12:34:56:78:90",
          "type":"primary",
          "requested":"Tue Feb 25 14:57:35 PST 2014"
        }
        "bluecheese.example.com":{
          "ip_addr" : "192.168.2.2", 
          "mac": 12:34:56:78:91",
          "type":"logical",
          "requested":"Tue Feb 25 14:57:35 PST 2014"
        }
      ]}'
    sut = IpResource.new(@input)
    puts sut.ip_addresses #should have 192.168.2.1, 192.168.2.2
  end
  
  def test_host_creation
    @input = '{
      "ranges": ["192.168.2.0/24"], 
      "entries": [
        "cheddarcheese.example.com":{
          "ip_addr" : "192.168.2.3", 
          "mac": 12:34:56:78:92",
          "type":"primary",
          "host":"cheddarcheese",
          "requested":"Tue Feb 25 14:57:35 PST 2014"
        }
        "cheddarcheese.example.com":{
          "ip_addr" : "192.168.2.4", 
          "mac": 12:34:56:78:92",
          "type":"logical",
          "host":"cheddarcheese",
          "requested":"Tue Feb 25 14:57:35 PST 2014"
        }
        "cheddarcheese.example.com":{
          "ip_addr" : "192.168.2.4", 
          "mac": 12:34:56:78:93",
          "type":"direct-return-interface-group",
          "host":"cheddarcheese",
          "requested":"Tue Feb 25 14:57:35 PST 2014"
        }
      ]}'
    sut = IpResource.new(@input)
    puts sut.hosts # should have cheddarcheese with 3 interfaces
  end
end
