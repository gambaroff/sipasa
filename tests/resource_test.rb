require 'test/unit'

require_relative("../ip_addr")

class TestResource <  Test::Unit::TestCase
  
  def test_creation
    @ranges = '["192.168.2.0/24", ["192.168.3.2", "192.168.3.9"]]'
    sut = IpResource.new(@ranges)
    output = sut.ip_ranges
    assert_equal Range, output[0].class #fails cuase it is currently a String
    assert_equal Range, output[1].class #Fails cause it is caurrently an Array
    assert_equal IPAddr.new("192.168.2.0"), output[0].first
    assert_equal IPAddr.new("192.168.2.255"), output[0].last
    assert_equal IPAddr.new("192.168.3.2"), output[1].first
    assert_equal IPAddr.new("192.168.3.9"), output[1].last

  end
  

end

=begin
my_hash = JSON.parse('{"hello": "goodbye"}')
#generate
my_hash = {:hello => "goodbye"}
puts JSON.generate(my_hash) => "{\"hello\":\"goodbye\"}"
=end