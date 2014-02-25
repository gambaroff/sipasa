require 'test/unit'

require_relative("../ip_addr")

class TestResource <  Test::Unit::TestCase
  
  def test_range_creation
    @ranges = '{"ranges": ["192.168.2.0/24", ["192.168.3.2", "192.168.3.9"]], "ips":[]}'
    sut = IpResource.new(@ranges)
    output = sut.ip_ranges
    assert_equal Range, output[0].class #fails cuase it is currently a String
    assert_equal Range, output[1].class #Fails cause it is caurrently an Array
    assert_equal IPAddr.new("192.168.2.0"), output[0].first
    assert_equal IPAddr.new("192.168.2.255"), output[0].last
    assert_equal IPAddr.new("192.168.3.2"), output[1].first
    assert_equal IPAddr.new("192.168.3.9"), output[1].last

  end
  
  def test_ip_creation
    @input = '{"ranges": ["192.168.2.0/24"], "ips": ["192.168.2.1", "192.168.2.4"]}'
    sut = IpResource.new(@input)
    puts sut.ip_ranges
  end
end
