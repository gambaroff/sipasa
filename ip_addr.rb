require 'json'
require 'ipaddr'

#ip_range = IPAddr.new("192.168.2.0")..IPAddr.new("192.168.2.6")

world = { ranges: [], used: [] }

ipfile = File.open("ipworld.json", "w")
ipfile.puts world.to_json
ipfile.close

ipfile2 = File.open("ipworld.json", "r")
myworld = JSON.parse(ipfile2.read)

class IPGenerator
  def initialize(world)
    @range = world.each{
      
    }
    @used
  end
end


ranges = ["192.168.2.0/24", ["192.168.3.2", "192.168.3.9"]]
 
ip_ranges = ranges.collect do |range|
  range.is_a?(String) ? IPAddr.new(range).to_range : IPAddr.new(range[0])..IPAddr.new(range[1])
end


