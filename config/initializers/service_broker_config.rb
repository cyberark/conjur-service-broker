Rails.application.config.service_broker = 
  YAML.load_file(Rails.root.join('config/service_broker.yml'))