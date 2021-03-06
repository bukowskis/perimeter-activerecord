require 'active_support/concern'

module Perimeter
  module Backend
    module Adapters
      module ActiveRecord
        extend ActiveSupport::Concern

        included do
          begin
            # ActiveRecord >= 3.2.1
            self.table_name = perimeter_table_name
          rescue NoMethodError => e
            # ActiveRecord < 3.2.1
            set_table_name perimeter_table_name
          end
        end

        module ClassMethods

          def perimeter_table_name(*args)
            @perimeter_table_name = args.first unless args.empty?
            @perimeter_table_name || default_perimeter_table_name
          end

          def default_perimeter_table_name
            name.split('::')[-2].underscore
          end

        end

      end
    end
  end
end
