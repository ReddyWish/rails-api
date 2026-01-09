class User < ApplicationRecord
  has_secure_password

  validates :name,
    presence: true,
    length: { minimum: 3, maximum: 50 }

  validates :email,
    presence: true,
    uniqueness: {
      case_sensitive: false
    },
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "must be a valid email address"
    }

  before_save :normalize_email

  private

  def normalize_email
    self.email = email.strip.downcase
  end
end
