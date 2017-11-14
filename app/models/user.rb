class User < ActiveRecord::Base
  include UserApiUpdates
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, #:confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :profile, dependent: :destroy, autosave: true
  has_many :schools, through: :counselor_assignments
  
  has_many :account_messages, inverse_of: :user
  has_many :chat_records, foreign_key: :sender_id
  has_many :counselor_assignments, inverse_of: :counselor, foreign_key: :counselor_id
  has_many :created_milestones, inverse_of: :owner, class_name: 'MilestoneListing', foreign_key: :owner_id  
  has_many :entry_likes, inverse_of: :liked_by, foreign_key: :liked_by_id
  has_many :personal_milestones, inverse_of: :assigned_to, class_name: 'MilestoneListing', foreign_key: :assigned_to_id
  
  after_create :make_blank_profile
  attr_accessor :first_name, :last_name

  delegate :full_name, to: :profile
  delegate :profile_entries, to: :profile
  delegate :school, to: :profile

  def self.publicly_found(slug)
    u = find_by_slug(slug)
    u.profile.published? ? u : nil
  end
  
  def name_with_school
    if (s = self.school)
      if s.class == Array
        str = s.map { |i| i.name }.join(', ')
        str = " (#{str})"
      else
        str = " (#{school.name})"
      end
    else
      str = ''
    end
    
    full_name + str
  end
    
  def inbox(unread: true)
    # Implement READ filter later TODO
    {unread_inbox: AccountInboxMessage.where(is_read: false).all.map(&:alerts_data)}
  end

  def students
    self.counselor? ? User.joins(:profile).where('(profiles.contact_details->>\'school_id\')::int in (?) and profiles.profile_type = ?',
                                                 self.counselor_assignments.pluck(:school_id), 'student')
                      : User.none
  end
  
  def counselors
    (self.student? && self.profile.school) ? self.profile.school.counselors : User.none
  end
  
  def valid_counselor_id?(id)
    counselors.pluck(:id).include?(id.to_i)
  end

  def student?
    is_a_type? :student
  end
  def counselor?
    is_a_type? :counselor
  end

  def public_link
    # identifier for use in public profile urls

    slug.present? ? slug : 
      # tr is a lot faster than gsub
      (self.slug = 'public___' + email.tr('+!.@-', '_____'); self.save; slug)
  end

  def friendships
    Friendship.where('first_friend_id = ? or second_friend_id = ?', id, id)
  end

  def make_friend(v)
    unless friendship_ids.include?(v.id)
      Friendship.create first_friend_id: self.id, second_friend_id: v.id
    end
  end

  def friend_entries(opts)
    ProfileEntry.left_outer_joins(:entry_likes).
      joins(profile: :user).where(
      'profile_entries.entry_key in (?) and users.id in (?)',
      opts[:of_type], friends.pluck(:id))
  end
  
  def friends
    fs = friendships.pluck :first_friend_id, :second_friend_id
    friend_ids = fs.map do |pair|
      pair[0] == self.id ? pair[1] : pair[0]
    end

    User.where('id in (?)', friend_ids)
  end

  private
  def friendship_ids
    friendships.pluck(:first_friend_id, :second_friend_id).flatten.uniq - [self.id]
  end
  
  def make_blank_profile
    p = Profile.new(
      user: self,
      contact_details: {}
    )
    p.save
  end
  
  def is_a_type?(sym)
    self.profile.present? && sym.present? && self.profile.profile_type.try(:to_sym) == sym
  end
end
