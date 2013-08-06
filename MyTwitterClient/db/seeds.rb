# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


u1 = User.create(:username => 'will', :twitter_user_id => '12')
u2 = User.create(:username => 'rashi', :twitter_user_id => '44')

u1.people_who_user_follows << u2
u2.people_who_user_follows << u1

u1.statuses.create!(:body => "Rashi is amazing! - Will",
                    :twitter_status_id => 46)
u2.statuses.create!(:body => "I agree! - Rashi", :twitter_status_id => 149)