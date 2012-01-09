$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'active_record'
require 'rspec'
require 'subly'
require 'sqlite3'

#Time.zone.now doesn't work in test


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

#ActiveRecord::Schema.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Base.logger = Logger.new('/dev/null')

ActiveRecord::Base.configurations = true
ActiveRecord::Schema.define(:version => 1) do
  create_table :items do |t|
    t.datetime  :created_at
    t.datetime  :updated_at
    t.string    :name
    t.string    :description
  end

  create_table :things do |t|
    t.datetime  :created_at
    t.datetime  :updated_at
    t.string    :name
    t.string    :description
  end

  create_table :subly_models do |t|
    t.datetime  :archived_at
    t.string    :subscriber_type
    t.integer   :subscriber_id
    t.string    :name
    t.string    :value
    t.datetime  :starts_at
    t.datetime  :ends_at
  end
  add_index :subly_models, [:subscriber_type,:subscriber_id], :name => 'subscriber_idx'
  add_index :subly_models, :starts_at, :name => 'starts_idx'
  add_index :subly_models, :ends_at, :name => 'ends_idx'
end
