

module Api
  module V1
    class AuthController < ApplicationController
      wrap_parameters false
      skip_before_action :authenticate_user, only: [ :signup, :login ], raise: false

      def signup
        @user = User.new(user_params)

        if @user.save
          token = JsonWebToken.encode(user_id: @user.id)

          set_token_cookie(token)

          render json: {
            user: user_response(@user),
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
          token = JsonWebToken.encode(user_id: @user.id)
          set_token_cookie(token)
          render json: {
            user: user_response(@user),
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
        token = cookies.signed[:token]

        payload = JsonWebToken.decode(token)

        if payload
          @user = User.find_by(id: payload[:user_id])

          if @user
            render json: {
              user: user_response(@user)
            }, status: :ok
          else
            render json: {
              error: "User not found"
            }, status: :not_found
          end
        else
          render json: {
            error: "Not authenticated"
          }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:name, :email, :password, :password_confirmation)
      end

      def set_token_cookie(token)
        cookies.signed[:token] = {
          value: token,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax,
          expires: 24.hours.from_now
        }
      end

      def user_response(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          created_at: user.created_at
        }
      end
    end
  end
end
