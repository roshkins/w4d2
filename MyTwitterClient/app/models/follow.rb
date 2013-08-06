class Follow < ActiveRecord::Base
  attr_accessible :follower_id, :user_id

  belongs_to  :as_user,
              :class_name => 'User',
              :foreign_key => :user_id,
              :primary_key => :twitter_user_id

  belongs_to  :as_follower,
              :class_name => 'User',
              :foreign_key => :follower_id,
              :primary_key => :twitter_user_id
end
