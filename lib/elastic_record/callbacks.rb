module ElasticRecord
  module Callbacks
    def self.included(base)
      base.class_eval do
        after_save do
          elastic_index.index_record self
        end

        after_destroy do
          elastic_index.delete_record self
        end
      end
    end
  end
end
