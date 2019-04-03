module Api
  class RequestParser
    def self.parse_user(data)
      user_name = Hash(data).fetch_path("requester", "user_name")
      return if user_name.blank?
      user = User.lookup_by_identity(user_name)
      raise BadRequestError, "Unknown requester user_name #{user_name} specified" unless user
      user
    end

    def self.parse_options(data)
      raise BadRequestError, "Request is missing options" if data["options"].blank?
      # Need to preserve string keys in dialog sub-hash while still supporting access by symbols
      dialog = data["options"].delete("dialog")
      data["options"].deep_symbolize_keys.tap do |hash|
        hash[:dialog] = dialog.with_indifferent_access if dialog.present?
      end
    end

    def self.parse_auto_approve(data)
      case data["auto_approve"]
      when TrueClass, "true" then true
      when FalseClass, "false", nil then false
      else raise BadRequestError, "Invalid requester auto_approve value #{data["auto_approve"]} specified"
      end
    end
  end
end
