class JSONValidator
  class << self
    def validate(path, json_body)
      [
          JSON::Validator.validate!(
              Rails.root.join("app/models/schemas/#{path}.json").to_s,
              json_body
          ),
          nil
      ]
    rescue JSON::Schema::ValidationError => e
      [
          false,
          e.message
      ]
    end
  end
end
