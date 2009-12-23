class CreateAwardableTables < ActiveRecord::Migration
  def self.up
    create_table :awards do |t|
      t.string   :name, :null => false, :unique => true
      t.string   :display_name, :null => false, :unique => true
      t.boolean  :once_global, :default => false
      t.boolean  :once_instance, :default => false
      t.integer  :prestige, :default => 0
      t.string   :masculine_title
      t.string   :feminine_title
      t.timestamps
    end
    
    create_table :awardings do |t|
      t.integer    :awardable_id
      t.string     :awardable_type
      t.references :award
      t.datetime   :created_at
    end

    add_index :awards, :name
    add_index :awardings, [:awardable_type, :awardable_id]
    add_index :awardings, :award_id
  end
  
  def self.down
    remove_index :awards, :name
    remove_index :awardings, [:awardable_type, :awardable_id]
    remove_index :awardings, :award_id

    drop_table :awardings
    drop_table :awards
  end
end
