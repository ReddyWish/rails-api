module Api
  module V1
    class PostsController < ApplicationController
      skip_before_action :authenticate_user, only: [ :index, :show ]

      before_action :set_post, only: [ :show, :update, :destroy ]

      before_action :authorize_user, only: [ :update, :destroy ]

      def index
        if params[:user_id]
          @posts = Post.includes(:user).by_user(params[:user_id]).recent
        else
          @posts = Post.includes(:user).recent
        end

        render json: {
          posts: @posts.map { |post| post_response(post) }
        }
      end

      def show
        render json: {
          post: post_response(@post)
        }, status: :ok
      end

      def create
        @post = current_user.posts.build(post_params)

        if @post.save
          render json: {
            post: post_response(@post),
            message: "Post created successfully"
          }, status: :created
        else
          render json: {
            errors: @post.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def update
        if @post.update(post_params)
          render json: {
            post: post_response(@post),
            message: "Post updated successfully"
          }, status: :ok
        else
          render json: {
            errors: @post.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def destroy
        @post.destroy

        render json: {
          message: "Post deleted successfully"
        }, status: :ok
      end

      def my_posts
        @posts = current_user.posts.includes(:user).recent

        render json: {
          posts: @posts.map { |post| post_response(post) }
        }, status: :ok
      end

      private

      def authorize_user
        unless @post.user_id == current_user.id
          render json: {
            error: "You are not authorized to perform this action"
          }, status: :forbidden
        end
      end

      def post_params
        params.require(:post).permit(:title, :description)
      end

      def set_post
        @post = Post.includes(:user).find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found" }, status: :not_found
      end

      def post_response(post)
        {
          id: post.id,
          title: post.title,
          description: post.description,
          author: {
            id: post.user.id,
            name: post.user.name,
            email: post.user.email
          },
          created_at: post.created_at,
          updated_at: post.updated_at
        }
      end
    end
  end
end
