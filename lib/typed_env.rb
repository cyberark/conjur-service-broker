class TypedEnv
  class << self
    TRUTHY_VALUES = %w(t true yes y 1).freeze

    def boolean(name)
      TRUTHY_VALUES.include?(ENV[name].to_s.downcase)
    end
  end
end
