$LOAD_PATH.unshift File.expand_path('../support/models', __FILE__)

require 'sqlite3'
require 'active_record'
require 'perimeter-activerecord'

RSpec.configure do |config|

  config.before(:each) do
    ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

    ActiveRecord::Schema.define do
      create_table :games do |table|
        table.column :genre, :string
        table.column :name, :string
        table.column :director, :string
        table.column :year, :integer
      end
    end

  end
end
