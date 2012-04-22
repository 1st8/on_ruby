class Wish < ActiveRecord::Base

  extend FriendlyId
  friendly_id :name, use: :slugged

  acts_as_api

  api_accessible :ios_v1 do |template|
    template.add :id
    template.add :name
    template.add :done
    template.add :stars
    template.add :user_id
  end

  validates :name, :description, :user, presence: true
  validates :name, uniqueness: true

  attr_accessible :name, :done, :stars, :description

  belongs_to :user

  has_many :votes, dependent: :destroy

  scope :done,    where(done: true).order('id DESC')
  scope :undone,  where(done: false).order('id DESC')
  scope :ordered, order('created_at DESC')

  def stars
    return 0.0 if votes.empty?
    (votes.sum(:count) / votes.count.to_f).round(1)
  end

  def already_voted?(user)
    votes.any?{|vote| vote.user == user}
  end

  def twitter_message(url)
    # TODO (ps) move to view
    I18n.t("wish.twitter_message", nickname: user.nickname, name: name.truncate(50), url: url)
  end

  def copy_to_topic!
    Topic.create!(name: name, description: description, user: user, event: Event.last)
    update_attributes!(done: true)
  end
end
