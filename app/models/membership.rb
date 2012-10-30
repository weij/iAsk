class Membership
  include Mongoid::Document
  include Mongoid::Timestamps

  ROLES = %w[user moderator owner]

  field :_id, :type => String
  default_scope where(:state => "active")

  field :state, :type => String, :default => 'active'
  field :display_name, :type => String
  field :group_id, :type => String
  field :reputation, :type => Float, :default => 0.0
  field :profile, :type => Hash, :default => {} # custom user keys
  field :votes_up, :type => Float, :default => 0.0
  field :votes_down, :type => Float, :default => 0.0
  field :views_count, :type => Float, :default => 0.0
  field :preferred_tags, :type => Array, :default => []
  field :last_activity_at, :type => Time
  field :joined_at, :type => Time
  field :activity_days, :type => Integer, :default => 0
  field :role, :type => String, :default => "user"

  field :bronze_badges_count,       :type => Integer, :default => 0
  field :silver_badges_count,       :type => Integer, :default => 0
  field :gold_badges_count,         :type => Integer, :default => 0
  field :is_editor,                 :type => Boolean, :default => false
  field :level,                     :type => Integer, :default => 1

  field :comments_count,            :type => Integer, :default => 0
  field :reputation_today, :type => Hash, :default => {}


  belongs_to :user
  belongs_to :group

  validates_inclusion_of :role,  :in => ROLES
  validates_presence_of :user
  validates_presence_of :group
  validates_uniqueness_of :user_id, :scope => [:group_id]

  index :group_id => 1
  index :user_id => 1
  index :reputation => 1
  index :state => 1
  index({user_id: 1, group_id: 1}, {unique: true})
  index({state: 1, group_id: 1})

  before_save :update_user_info
  after_create :add_to_user
  after_destroy :remove_from_user

  def method_missing(name, *args, &block)
    self.user.send(name, *args, &block)
  end

  protected
  def update_user_info
    self.display_name = user.login
  end

  def add_to_user
    self.user.push_uniq(:group_ids => self.group_id)
  end

  def remove_from_user
    self.user.pull(:group_ids => self.group_id)
  end
end
