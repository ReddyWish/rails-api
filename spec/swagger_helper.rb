# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Blog API V1',
        version: 'v1',
        description: 'A RESTful API for a blog application with authentication and posts management'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ],
      components: {
        securitySchemes: {
          cookieAuth: {
            type: :apiKey,
            in: :cookie,
            name: :token,
            description: 'JWT token stored in HTTP-only cookie'
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'John Doe' },
              email: { type: :string, format: :email, example: 'john@example.com' },
              created_at: { type: :string, format: 'date-time' }
            },
            required: %w[id name email created_at]
          },
          Post: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              title: { type: :string, example: 'My First Post' },
              description: { type: :string, example: 'This is the post content...' },
              author: { '$ref' => '#/components/schemas/Author' },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            },
            required: %w[id title description author created_at updated_at]
          },
          Author: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'John Doe' },
              email: { type: :string, format: :email, example: 'john@example.com' }
            },
            required: %w[id name email]
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: 'Error message' }
            }
          },
          ValidationErrors: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string },
                example: ["Email can't be blank", "Password is too short"]
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file (json or yaml)
  config.openapi_format = :yaml
end
