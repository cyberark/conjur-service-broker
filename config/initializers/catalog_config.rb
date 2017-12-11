Rails.application.config.catalog =
    YAML.load_file(Rails.root.join('config/catalog.yml'))
