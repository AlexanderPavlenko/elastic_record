module ElasticRecord
  class Railtie < Rails::Railtie
    initializer 'elastic_record.require_log_subscriber' do
      require 'elastic_record/log_subscriber'
    end

    rake_tasks do
      load "elastic_record/tasks/index.rake"
    end

    # Expose database runtime to controller for logging.
    initializer "elastic_record.log_runtime" do |app|
      require "elastic_record/railties/controller_runtime"
      ActiveSupport.on_load(:action_controller) do
        include ElasticRecord::Railties::ControllerRuntime
      end
    end
  end
end
