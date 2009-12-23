class AwardableGenerator < Rails::Generator::Base 
  def manifest 
    record do |m| 
      m.migration_template 'db/migrate/migration.rb',
        'db/migrate',
        :migration_file_name => "create_awardable_tables"
      m.template 'app/models/award.rb', 'app/models/award.rb'
      m.template 'app/models/awarding.rb', 'app/models/awarding.rb'
    end
  end
end
