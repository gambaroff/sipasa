require 'active_record'
 
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'ips.db')
 
ActiveRecord::Schema.define do
  create_table :ips do |t|
    t.column :id, :integer
    t.column :name, :string
    t.column :value, :string
  end
end