# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Auth API', type: :request do
  path '/api/v1/signup' do
    post 'Register a new user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'John Doe' },
          email: { type: :string, format: :email, example: 'john@example.com' },
          password: { type: :string, minLength: 6, example: 'password123' },
          password_confirmation: { type: :string, example: 'password123' }
        },
        required: %w[name email password]
      }

      response '201', 'User created successfully' do
        schema type: :object,
               properties: {
                 user: { '$ref' => '#/components/schemas/User' },
                 message: { type: :string, example: 'Account created successfully' }
               },
               required: %w[user message]

        let(:user) { { name: 'John Doe', email: 'john@example.com', password: 'password123' } }
        run_test!
      end

      response '422', 'Validation errors' do
        schema '$ref' => '#/components/schemas/ValidationErrors'

        let(:user) { { name: '', email: 'invalid', password: '123' } }
        run_test!
      end
    end
  end

  path '/api/v1/login' do
    post 'Authenticate user and receive token cookie' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email, example: 'john@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: %w[email password]
      }

      response '200', 'Logged in successfully' do
        schema type: :object,
               properties: {
                 user: { '$ref' => '#/components/schemas/User' },
                 message: { type: :string, example: 'Logged in successfully' }
               },
               required: %w[user message]

        let(:existing_user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        let(:credentials) { { email: existing_user.email, password: 'password123' } }
        run_test!
      end

      response '401', 'Invalid credentials' do
        schema '$ref' => '#/components/schemas/Error'

        let(:credentials) { { email: 'wrong@example.com', password: 'wrong' } }
        run_test!
      end
    end
  end

  path '/api/v1/logout' do
    delete 'Log out current user' do
      tags 'Authentication'
      produces 'application/json'
      security [ cookieAuth: [] ]

      response '200', 'Logged out successfully' do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Logged out successfully' }
               },
               required: %w[message]

        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        before { sign_in(user) }
        run_test!
      end
    end
  end

  path '/api/v1/me' do
    get 'Get current authenticated user' do
      tags 'Authentication'
      produces 'application/json'
      security [ cookieAuth: [] ]

      response '200', 'Current user retrieved' do
        schema '$ref' => '#/components/schemas/User'

        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        before { sign_in(user) }
        run_test!
      end

      response '401', 'Not authenticated' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
