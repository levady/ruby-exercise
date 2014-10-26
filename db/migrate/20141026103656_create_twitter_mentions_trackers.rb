class CreateTwitterMentionsTrackers < ActiveRecord::Migration
  def change
    create_table :twitter_mentions_trackers do |t|
      t.integer :twitter_id, limit: 8

      t.timestamps
    end
    add_index :twitter_mentions_trackers, :twitter_id
  end
end
