class PostSerializer
  def initialize(post)
    @post = post
  end

  def as_json
    {
      id: @post.id,
      title: @post.title,
      description: @post.description,
      author: UserSerializer.new(@post.user).as_json,
      created_at: @post.created_at,
      updated_at: @post.updated_at
    }
  end
end
