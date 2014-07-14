require 'my/game'
require 'my/games/backend'
require 'perimeter/repository/adapters/active_record'

module My
  module Games
    include Perimeter::Repository::Adapters::ActiveRecord
  end
end
