module Storey
  module ActiveRecord
    module Descendants

      extend ActiveSupport::Concern

      module ClassMethods
        def descendants
          ObjectSpace.each_object(Class).select { |klass| klass < self }
        end
      end

    end
  end
end

::ActiveRecord::Base.send :include, Storey::ActiveRecord::Descendants
