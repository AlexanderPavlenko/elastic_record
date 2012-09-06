require 'elastic_record/index/documents'
require 'elastic_record/index/manage'
require 'elastic_record/index/mapping'
require 'elastic_record/index/percolator'
require 'net/http'

module ElasticRecord
  class Index
    include Documents
    include Manage
    include Mapping
    include Percolator

    attr_accessor :model
    attr_accessor :disabled

    def initialize(model)
      @model = model
      @disabled = false
    end

    def alias_name
      @alias_name ||= model.base_class.model_name.collection
    end

    def percolator_name
      @percolator_name ||= "percolate_#{alias_name}"
    end

    def type
      @type ||= model.base_class.model_name.element
    end

    def disable!
      @disabled = true
    end

    def enable!
      @disabled = false
    end

    private
      def new_index_name
        "#{alias_name}_#{Time.now.to_i}"
      end

      def json_get(path, json = nil)
        json_request Net::HTTP::Get, path, json
      end

      def json_post(path, json = nil)
        json_request Net::HTTP::Post, path, json
      end

      def json_put(path, json = nil)
        json_request Net::HTTP::Put, path, json
      end

      def json_delete(path, json = nil)
        json_request Net::HTTP::Delete, path, json
      end

      def json_request(request_klass, path, json)
        request = request_klass.new(path)
        if json
          request.body = ActiveSupport::JSON.encode(json)
        end

        # p "#{request.class.name} #{path}: #{request.body}"

        ActiveSupport::JSON.decode http.request(request).body
      end

      def connection
        @model.elastic_connection
      end

      def http
        host, port = connection.current_server.split ':'
        Net::HTTP.new(host, port)
      end
  end
end