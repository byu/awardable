ActiveRecord::Schema.define :version => 0 do

  create_table :awards, :force => true do |t|
    t.string   :name, :null => false, :unique => true
    t.string   :display_name, :null => false, :unique => true
    t.boolean  :once_global, :default => false
    t.boolean  :once_instance, :default => false
    t.integer  :prestige, :default => 0
    t.string   :masculine_title
    t.string   :feminine_title
    t.timestamps
  end
  
  create_table :awardings, :force => true do |t|
    t.integer    :awardable_id
    t.string     :awardable_type
    t.references :award
    t.datetime   :created_at
    t.string     :some_option
  end

  create_table :awardable_models, :force => true do |t|
    t.string :name
    t.string :type
  end

end
