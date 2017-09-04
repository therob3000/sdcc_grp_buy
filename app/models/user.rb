class User < ApplicationRecord
  include SecurityHelper
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]
  has_many :members
  has_many :purchases
  has_many :groups
  has_many :direct_messages


	def self.from_omniauth(auth)
    if User.exists?(:email => auth.info.email)
      user = User.find_by_email(auth.info.email)
      user.update_attributes(avatar_url: auth.info.image)
      user
    else
      user = User.create(name: auth.extra.raw_info.name, email: auth.info.email, avatar_url: auth.info.image, password: Devise.friendly_token[0,20])
    end
    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def is_valid?
    # this users validation_code must match thier assigned e-mail in the ValidationCode model
    code = ValidationCode.validate_by_email(email, decrypt_code(validation_code))
  end

  def is_admin?
    is_admin == true
  end

  def has_unread_messages
    direct_messages.any? { |e| e.seen == false }
  end

  def my_groups
    out = []

    # all groups created by user
    groups.each do |grp|
      out << grp
    end

    # all groups with a member created/sponsored by user
    members.each do |mem|
      mem.member_groups.each do |mg|
        out << mg.group
      end
    end      

    out.uniq
  end
end
