require 'perimeter/backend/adapters/active_record'

module My
  module Games
    class Backend < ActiveRecord::Base

      include Perimeter::Backend::Adapters::ActiveRecord

      validates :genre, presence: true

      before_validation :set_director

      private

      def set_director
        self.director = 'Gene Roddenberry'
      end

    end
  end
end
