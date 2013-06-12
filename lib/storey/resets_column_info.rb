module Storey
  class ResetsColumnInfo

    easy_class_to_instance

    def execute
      descendants.each do |descendant|
        descendant.reset_column_information
      end
    end

    private

    def descendants
      @descendants ||= ObjectSpace.each_object(Class).select do |klass|
        klass < ActiveRecord::Base
      end
    end

  end
end
