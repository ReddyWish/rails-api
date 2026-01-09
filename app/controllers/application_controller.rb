class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :authenticate_user

  attr_reader :current_user

  private

  def authenticate_user
    token = cookies.signed[:token]

    payload = JsonWebToken.decode(token)

    if payload && (@current_user = User.find_by(id: payload[:user_id]))
    else
      render json: {
        error: "You must be logged in to access this resource"
      }, status: :unauthorized
    end
  end
end
