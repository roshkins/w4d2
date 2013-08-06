class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, :unique => true
      t.integer :twitter_user_id
      t.timestamps
    end

    add_index :users, :twitter_user_id
  end
end
