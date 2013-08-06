class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :body

      t.integer :twitter_status_id
      t.integer :user_id

      t.timestamps
    end

    add_index :statuses, :user_id
  end
end
