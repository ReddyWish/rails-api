# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Posts API', type: :request do
  path '/api/v1/posts' do
    get 'List all posts' do
      tags 'Posts'
      produces 'application/json'

      response '200', 'Posts retrieved' do
        schema type: :object,
               properties: {
                 posts: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/Post' }
                 }
               },
               required: %w[posts]

        run_test!
      end
    end

    post 'Create a new post' do
      tags 'Posts'
      consumes 'application/json'
      produces 'application/json'
      security [cookieAuth: []]

      parameter name: :post_params, in: :body, schema: {
        type: :object,
        properties: {
          post: {
            type: :object,
            properties: {
              title: { type: :string, example: 'My Post Title' },
              description: { type: :string, example: 'This is the post content...' }
            },
            required: %w[title description]
          }
        },
        required: %w[post]
      }

      response '201', 'Post created successfully' do
        schema type: :object,
               properties: {
                 post: { '$ref' => '#/components/schemas/Post' },
                 message: { type: :string, example: 'Post created successfully' }
               },
               required: %w[post message]

        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        let(:post_params) { { post: { title: 'Test Post', description: 'Test content' } } }
        before { sign_in(user) }
        run_test!
      end

      response '401', 'Not authenticated' do
        schema '$ref' => '#/components/schemas/Error'
        let(:post_params) { { post: { title: 'Test', description: 'Test' } } }
        run_test!
      end

      response '422', 'Validation errors' do
        schema '$ref' => '#/components/schemas/ValidationErrors'

        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        let(:post_params) { { post: { title: '', description: '' } } }
        before { sign_in(user) }
        run_test!
      end
    end
  end

  path '/api/v1/posts/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Post ID'

    get 'Get a specific post' do
      tags 'Posts'
      produces 'application/json'

      response '200', 'Post retrieved' do
        schema type: :object,
               properties: {
                 post: { '$ref' => '#/components/schemas/Post' }
               },
               required: %w[post]

        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        let(:post_record) { Post.create!(title: 'Test', description: 'Test', user: user) }
        let(:id) { post_record.id }
        run_test!
      end

      response '404', 'Post not found' do
        schema '$ref' => '#/components/schemas/Error'
        let(:id) { 999999 }
        run_test!
      end
    end

    put 'Update a post' do
      tags 'Posts'
      consumes 'application/json'
      produces 'application/json'
      security [cookieAuth: []]

      parameter name: :post_params, in: :body, schema: {
        type: :object,
        properties: {
          post: {
            type: :object,
            properties: {
              title: { type: :string, example: 'Updated Title' },
              description: { type: :string, example: 'Updated content...' }
            }
          }
        },
        required: %w[post]
      }

      response '200', 'Post updated successfully' do
        schema type: :object,
               properties: {
                 post: { '$ref' => '#/components/schemas/Post' },
                 message: { type: :string, example: 'Post updated successfully' }
               },
               required: %w[post message]

        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        let(:post_record) { Post.create!(title: 'Test', description: 'Test', user: user) }
        let(:id) { post_record.id }
        let(:post_params) { { post: { title: 'Updated Title' } } }
        before { sign_in(user) }
        run_test!
      end

      response '401', 'Not authenticated' do
        schema '$ref' => '#/components/schemas/Error'
        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        let(:post_record) { Post.create!(title: 'Test', description: 'Test', user: user) }
        let(:id) { post_record.id }
        let(:post_params) { { post: { title: 'Updated' } } }
        run_test!
      end

      response '403', 'Not authorized to update this post' do
        schema '$ref' => '#/components/schemas/Error'

        let(:owner) { User.create!(name: 'Owner', email: 'owner@example.com', password: 'password123') }
        let(:other_user) { User.create!(name: 'Other', email: 'other@example.com', password: 'password123') }
        let(:post_record) { Post.create!(title: 'Test', description: 'Test', user: owner) }
        let(:id) { post_record.id }
        let(:post_params) { { post: { title: 'Hacked!' } } }
        before { sign_in(other_user) }
        run_test!
      end

      response '404', 'Post not found' do
        schema '$ref' => '#/components/schemas/Error'
        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        let(:id) { 999999 }
        let(:post_params) { { post: { title: 'Updated' } } }
        before { sign_in(user) }
        run_test!
      end
    end

    delete 'Delete a post' do
      tags 'Posts'
      produces 'application/json'
      security [cookieAuth: []]

      response '200', 'Post deleted successfully' do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Post deleted successfully' }
               },
               required: %w[message]

        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        let(:post_record) { Post.create!(title: 'Test', description: 'Test', user: user) }
        let(:id) { post_record.id }
        before { sign_in(user) }
        run_test!
      end

      response '403', 'Not authorized to delete this post' do
        schema '$ref' => '#/components/schemas/Error'

        let(:owner) { User.create!(name: 'Owner', email: 'owner@example.com', password: 'password123') }
        let(:other_user) { User.create!(name: 'Other', email: 'other@example.com', password: 'password123') }
        let(:post_record) { Post.create!(title: 'Test', description: 'Test', user: owner) }
        let(:id) { post_record.id }
        before { sign_in(other_user) }
        run_test!
      end
    end
  end

  path '/api/v1/me/posts' do
    get 'List current user posts' do
      tags 'Posts'
      produces 'application/json'
      security [cookieAuth: []]

      response '200', 'User posts retrieved' do
        schema type: :object,
               properties: {
                 posts: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/Post' }
                 }
               },
               required: %w[posts]

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

  path '/api/v1/users/{user_id}/posts' do
    parameter name: :user_id, in: :path, type: :integer, description: 'User ID'

    get 'List posts by a specific user' do
      tags 'Posts'
      produces 'application/json'

      response '200', 'User posts retrieved' do
        schema type: :object,
               properties: {
                 posts: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/Post' }
                 }
               },
               required: %w[posts]

        let(:user) { User.create!(name: 'John', email: 'john@example.com', password: 'password123') }
        let(:user_id) { user.id }
        run_test!
      end
    end
  end
end
