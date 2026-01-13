

module Api
  module V1
    class AuthController < ApplicationController
      wrap_parameters false
      skip_before_action :authenticate_user, only: [ :signup, :login ], raise: false

      AUTH_EXPIRATION = 24.hours

      def signup
        @user = User.new(user_params)

        if @user.save
          token = JsonWebToken.encode({ user_id: @user.id }, AUTH_EXPIRATION.from_now)

          set_token_cookie(token, AUTH_EXPIRATION)

          render json: {
            user: UserSerializer.new(@user).as_json,
            message: "Account created successfully"
          }, status: :created
        else
          render json: {
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def login
        @user = User.find_by("LOWER(email) = ?", params[:email].downcase)

        if @user&.authenticate(params[:password])
          token = JsonWebToken.encode({ user_id: @user.id }, AUTH_EXPIRATION.from_now)
          set_token_cookie(token, AUTH_EXPIRATION)
          render json: {
            user: UserSerializer.new(@user).as_json,
            message: "Logged in successfully"
          }, status: :ok
        else
          render json: {
            error: "Invalid email or password"
          }, status: :unauthorized
        end
      end

      def logout
        cookies.delete(:token)

        render json: {
          message: "Logged out successfully"
        }, status: :ok
      end

      def me
       render json: UserSerializer.new(current_user).as_json, status: :ok
      end

      private

      def user_params
        params.permit(:name, :email, :password, :password_confirmation)
      end

      def set_token_cookie(token, expiration_duration)
        cookies.signed[:token] = {
          value: token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax,
          expires: expiration_duration.from_now
        }
      end
    end
  end
end
