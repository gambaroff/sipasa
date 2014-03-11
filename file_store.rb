class JsonStore

  def initialize(filename = "ipworld.json")
    @@datastore ||= filename
    unless File.exist?(@@datastore)
      empty = File.open(@@datastore, "w")
      empty.puts '{}'
      empty.close
    end
  end

  def store(world)
    ipfile = File.open(@@datastore, "w")
    ipfile.puts world.to_json
    ipfile.close
  end

  def retrieve()
    ipfile = File.open(@@datastore, "r")
    ipfile.read
  end
end