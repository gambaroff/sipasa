class JsonStore
  def initialize(filename = "ipworld.json")
    @datastore = filename
  end

  def store(world)
    ipfile = File.open(datastore, "w")
    ipfile.puts world.to_json
    ipfile.close
  end

  def retrieve()
    ipfile2 = File.open(datastore, "r")
    JSON.parse(ipfile2.read)
  end
end