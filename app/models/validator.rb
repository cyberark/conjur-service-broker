class Validator
  class << self
    def validate(schema_path, json_body)
      JSON::Validator.validate!(
          Rails.root.join("app/models/schemas/#{schema_path}.json").to_s,
          json_body
      )
    rescue JSON::Schema::ValidationError => e
      raise ValidationError.new(e.message)
    end
  end
end
