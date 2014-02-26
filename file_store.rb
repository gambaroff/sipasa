class JsonStore
  # if file doesnt exist, start it with : world = { ranges: [], used: [] }

  def initialize(filename = "ipworld.json")
    @datastore = filename
    if !File.exist?(filename)
      empty = File.open(@datastore, "w")
      empty.puts '{"pools": {}}'
      empty.close
    end
  end

  def store(world)
    ipfile = File.open(@datastore, "w")
    ipfile.puts world.to_json
    ipfile.close
  end

  def retrieve()
    ipfile = File.open(@datastore, "r")
    ipfile.read
  end
end