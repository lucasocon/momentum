class User < ActiveRecord::Base
  # devise :database_authenticatable, :registerable,
  #       :recoverable, :rememberable, :trackable, :validatable,
  #       :omniauthable, :omniauth_providers => [:facebook]
  devise :database_authenticatable, :rememberable, :trackable, :validatable,
        :omniauthable, :omniauth_providers => [:facebook]

  has_many :recommendations, dependent: :destroy

  def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
      end
  end
end
