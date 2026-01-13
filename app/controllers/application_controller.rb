class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :authenticate_user

  attr_reader :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity

  rescue_from UnauthorizedError, with: :render_forbidden

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

  def render_error(errors, status:)
    render json: ErrorSerializer.new(errors, status: status).as_json,
           status: status
  end

  def render_not_found(exception = nil)
    message = exception&.message || "Resource not found"
    render_error(message, status: :not_found)
  end

  def render_unauthorized(message = "Not authenticated")
    render_error(message, status: :unauthorized)
  end

  def render_forbidden(exception = nil)
    message = exception&.message || "You are not authorized to perform this action"
    render_error(message, status: :forbidden)
  end

  def render_unprocessable_entity(exception)
    render_error(exception.record.errors, status: :unprocessable_entity)
  end
end
