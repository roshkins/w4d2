class Status < ActiveRecord::Base
  attr_accessible :body, :user_id, :twitter_status_id

  belongs_to  :user,
              :class_name  => 'User',
              :foreign_key => :user_id,
              :primary_key => :twitter_user_id

  def self.parse_twitter_status(json)

    result = JSON.parse(json)

    result_hash = {}
    result_hash[:body] = result['text']
    result_hash[:twitter_status_id] = result['id']
    result_hash[:user_id] =result['user']['id']
    Status.new(result_hash)
  end
end
