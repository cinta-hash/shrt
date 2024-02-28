class Link < ApplicationRecord
    belongs_to :user

    validates :short_url, presence: true, uniqueness: true
    validates :long_url, presence: true


  private

  def generate_short_url
    self.short_url = SecureRandom.hex(4)
  end
end
