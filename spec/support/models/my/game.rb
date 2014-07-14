require 'perimeter/entity'

module My
  class Game
    include Perimeter::Entity

    attribute :name
    attribute :genre
    attribute :director

  end
end
