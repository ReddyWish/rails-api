# frozen_string_literal: true

module AuthHelper
  def sign_in(user)
    token = JsonWebToken.encode({ user_id: user.id }, 24.hours.from_now)
    cookies[:token] = token
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
