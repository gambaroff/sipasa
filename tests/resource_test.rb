require 'test/unit'

require_relative("../ip_addr")

class TestResource <  Test::Unit::TestCase
  
  def test_creation
    @ranges = '["192.168.2.0/24", ["192.168.3.2", "192.168.3.9"]]'
    sut = IpResource.new(@ranges)
    puts sut.ip_ranges
    assert_equal Range, @ranges[0].class #fails cuase it is currently a String
    assert_equal Range, @ranges[1].class #Fails cause it is caurrently an Array
    assert_equal ip_ranges[0], ip_ranges["192.168.2.0..192.168.2.255"]
    assert_equal ip_ranges[1], ip_ranges["192.168.3.2..192.168.3.9"]
    # actually do this test
    # ip_ranges should be an array with 2 entries.  Each entry is a ranges:
    # 192.168.2.0..192.168.2.255
    # and
    # 192.168.3.2..192.168.3.9
  end
  

end

=begin
my_hash = JSON.parse('{"hello": "goodbye"}')
#generate
my_hash = {:hello => "goodbye"}
puts JSON.generate(my_hash) => "{\"hello\":\"goodbye\"}"
=end