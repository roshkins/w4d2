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

  def sync_followers
    url = Addressable::URI.new(
    :scheme => "https",
    :host   => "api.twitter.com",
    :path   => "1.1/followers/ids.json",
    :query_values => {"user_id" => self.twitter_user_id}
    )
    result = JSON.parse(TwitterSession.get(url.to_s))
    result['ids'].each do |id|
      Follow.create!(:user_id => self.twitter_user_id, :follower_id => id)
    end
     create_users_from_ids(result['ids'])
  end

  def sync_followed_users
    url = Addressable::URI.new(
    :scheme => "https",
    :host   => "api.twitter.com",
    :path   => "1.1/friends/ids.json",
    :query_values => {"user_id" => self.twitter_user_id}
    )
    result = JSON.parse(TwitterSession.get(url.to_s))
    result['ids'].each do |id|
      Follow.create!(:user_id => id, :follower_id => self.twitter_user_id)
    end
    create_users_from_ids(result['ids'])
  end

  def sync_statuses
    url = Addressable::URI.new(
    :scheme => "https",
    :host   => "api.twitter.com",
    :path   => "1.1/statuses/user_timeline.json",
    :query_values => {"user_id" => self.twitter_user_id}
    )
    results = JSON.parse(TwitterSession.get(url.to_s))
    results.each do |result|
      unless Status.find_by_twitter_status_id(result['id'])
        new_status = Status.create!(:body => result['text'],
        :twitter_status_id => result['id'], :user_id => result['user']['id'])
        new_status.save!
      end
    end
  end

protected

  def create_users_from_ids(array_of_user_ids)
    #maybe redo this in the future
    url = Addressable::URI.new(
    :scheme => "https",
    :host   => "api.twitter.com",
    :path   => "1.1/users/lookup.json",
    :query_values => {"user_id" => array_of_user_ids * ",",
      "include_entities" => "false"}
    )

    results = JSON.parse(TwitterSession.get(url.to_s))
    results.each do |result|
      unless User.find(result['id'])
      User.create!(:username => result['screen_name'],
       :twitter_user_id => result['id'])
     end
    end
  end
end
