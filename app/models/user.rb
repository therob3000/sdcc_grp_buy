class User < ApplicationRecord
  include SecurityHelper
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]
  has_many :members, :dependent => :delete_all
  has_many :purchases, :dependent => :delete_all
  has_many :text_message_records, :dependent => :delete_all
  has_many :groups, :dependent => :delete_all
  has_many :followed_groups, :dependent => :delete_all
  has_many :direct_messages, :dependent => :delete_all
  validates_uniqueness_of :name, :email
  validate :filter_whitelist
  after_create :transfer_member_self



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

  def filter_whitelist
    # populate with admins
    emails = ["ncdsbuyinggroup@gmail.com", "beckymcholland@cox.net","laomatt1@gmail.com"]
    # get rest emails from the database of invitees from Invite model
    invite_emails = Invite.all.map { |e| e.email }

    total_emails = invite_emails + emails

    if !total_emails.include?(email)
      errors.add(:email, "#{email} is not invited to this app.")
    end

  end

  def is_buying_for?(member)
    if (member.sponsor_id == id) || !member.active
      return true
    else
      return false
    end
  end

  def member_belongs()
    # grp && (current_user.members.map { |e| e.id }.include?(mem_grp.try(:member).try(:id)))
  end

  def is_valid?
    # this users validation_code must match thier assigned e-mail in the ValidationCode model
    code = ValidationCode.validate_by_email(email, decrypt_code(validation_code))
  end

  def contact_info(viewing_user)
    if viewing_user.is_valid?
      "#{name} / #{email}"
    else
      "---protected---"
    end
  end

  def is_admin?
    is_admin == true
  end

  def has_a_val_code?
    val_code = ValidationCode.find_by_email(email)
    !val_code.nil?
  end

  def has_unread_messages
    direct_messages.any? { |e| e.seen == false }
  end

  def has_member(member)
    if members.include?(member)
      return true
    end
    false
  end

  def my_groups
    out = []

    # all groups created by user
    groups.each do |grp|
      out << grp
    end

    # all groups followed by user
    followed_groups.all.each do |grp|
      out << grp.group
    end

    # all groups with a member created/sponsored by user
    members.each do |mem|
      mem.member_groups.each do |mg|
        out << mg.group
      end
    end



    out.uniq
  end


  private

  def transfer_member_self
    member_self = Member.find_by_email(email)
    if member_self
      member_self.user_id = id
      member_self.save
    end
  end
end
