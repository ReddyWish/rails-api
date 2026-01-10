class Post < ApplicationRecord
  belongs_to :user

  validates :title,
    presence: true,
    length: {
      minimum: 3,
      maximum: 200,
      too_short: "must be at least %{count} characters",
      too_long: "must be at most %{count} characters"
    }

    validates :description,
    presence: true,
    length: {
      minimum: 10,
      maximum: 10_000,
      too_short: "must be at least %{count} characters",
      too_long: "must be at most %{count} characters"
    }

    scope :recent, -> { order(created_at: :desc) }

    scope :by_user, ->(user_id) { where(user_id: user_id) }
end
