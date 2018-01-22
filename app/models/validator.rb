class Validator
  class << self
    def validate(schema_path, json_body)
      JSON::Validator.validate!(
          Rails.root.join("app/models/schemas/#{schema_path}.json").to_s,
          json_body
      )
    rescue JSON::Schema::ValidationError => e
      e.message.gsub! /did not match the regex.*/, "was invalid."
      raise ValidationError.new(e.message)
    end
  end
end
