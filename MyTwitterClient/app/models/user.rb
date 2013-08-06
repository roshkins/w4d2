class User < ActiveRecord::Base
  attr_accessible :username, :twitter_user_id

  has_many  :followers,
            :class_name   => 'Follow',
            :foreign_key  => :user_id,
            :primary_key  => :twitter_user_id

  has_many  :people_who_user_follows,
            :through      => :followers,
            :source       => :as_follower

  has_many  :follows,
            :class_name   => 'Follow',
            :foreign_key  => :follower_id,
            :primary_key  => :twitter_user_id

  has_many  :people_who_follow_user,
            :through      => :follows,
            :source       => :as_user

  has_many  :statuses,
            :class_name   => 'Status',
            :foreign_key  => :user_id,
            :primary_key  => :twitter_user_id

  has_many  :followed_user_statuses,
            :through      => :people_who_user_follows,
            :source       => :statuses

  def self.parse_twitter_user(json)
    #find :twitter_user_id, :username
    result = JSON.parse(json)
    result_hash = {:twitter_user_id => result['id'],
                   :username => result['screen_name']}
    User.new(result_hash)
  end

end
