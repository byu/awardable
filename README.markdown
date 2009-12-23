Awardable
=========

Awardable is a Ruby on Rails plugin for projects that want to give
badges (or trophies, or achievements) to their Users (or any other
ActiveRecord model).

Links
-----
* Repository - <http://github.com/byu/awardable>
* Yard/RDocs - <http://rdoc.info/projects/byu/awardable>
* Issues - <http://github.com/byu/awardable/issues>

*Questions?* Message one of the Authors listed below.

Installation and Usage
======================

Install the gem from gemcutter:

> sudo gem install awardable

As a plugin:

> script/plugin install git://github.com/byu/awardable.git

Then add it to the project `Gemfile`.

> gem 'awardable'

Or add it into the `config/environment.rb` file:

> config.gem 'awardable'

Then create the migrations:

> script/generate awardable

It will create the following files:

> exists  db/migrate  
> create  db/migrate/20091220000000_create_awardable_tables.rb  
> create  app/models/award.rb  
> create  app/models/awarding.rb  

Migrate the database:

> rake db:migrate

Then pick the model to which you want to associate awards:

    class Character < ActiveRecord::Base
      acts_as_awardable
    end

At this point, you can use the plugin and models as described in the
`Example Usage` section. And you'll go about creating the controllers
and views for your Awards in the system.

However, this base install probably won't be enough to cover your
application's needs. `Extending the Models` section will describe
some added ways to add more features to Awardable in your application.

Example Usage
-------------

Let's say we have a hypothetical online game. It's like many MMO
games with characters, quests and acheivments. Here's a following
example of Awardable in that setting.

    # We create an Award, saving it to the database. Note that the
    # name must match the regular expression for a string with just lower
    # case alpha, numbers and underscores. Descriptive names should be
    # set in the display_name field. This is so code can reference
    # the name instead of a database integer id; better readability
    # if your application grants special access to sections of the
    # website if a user has a specific award.
    # The following is an award that an Awardable can achieve multiple
    # times.
    #
    # An award can have also title associated with it. The Award model saves
    # both the masculine and feminine forms of the title, but both are
    # optional. The Awardable model (e.g. - User) has a method to generate
    # the awarded titles based on varying options. See the documentation
    # for the specific options.
    award = Award.create(
      :name => 'marksman',
      :display_name => 'Bullseye: 3 Headshots in a Row',
      :masculine_title => 'Marksman',
      :feminine_title => 'Markswoman')

    # An award that can only be given once, ever in the system.
    # This type of award must be taken away from its current holder
    # before it can be given to another.
    global_award = Award.create(
      :name => 'captain_serenity_ship',
      :display_name => 'Captain: The Serenity',
      :masculine_title => 'Captain of the Serenity',
      :prestige => 1,
      :once_global => true)

    # An award that can only be achieved once per ActiveRecord instance.
    instance_award = Award.create(
      :name => 'battle_serenity_valley_winner',
      :display_name => 'QuestLine: Winner of the Battle of Serenity Valley',
      :masculine_title => 'Veteran of Serenity Valley',
      :feminine_title => 'Veteran of Serenity Valley',
      :once_instance => true)

    # This assigns and then saves a user's Character model.
    mal = Character.new(:name => 'Malcolm Reynolds')
    mal.award_with!(award)

    # Or assign by name. Note that #to_s is called on any non-Award object.
    mal.award_with!(:captain_serenity_ship)

    # Or by ActiveRecord relations
    mal.awards << award
    mal.save

    mal.awarded_with?(award)
    # => true

    mal.awarded_with?(:captain_serenity_ship)
    # => true

    mal.awarded_with?(:battle_serenity_valley_winner)
    # => false

    # Find all the users that have this award
    Character.find_with_award(:battle_serenity_valley_winner)
    # => [ ]

    Character.find_with_award(award)
    # => [ user ]

    # Awards can be awarded to a user multiple times, but what if we want
    # to iterate over each once? We get the unique set:
    mal.awards_set
    # => Set{...}

    # We can get a quick overview count of the awards this character has won.
    mal.awards_count
    # => { :captain_serenity_ship => 1, :marksman => 2 }

    # This gets the user's titles. Options include:
    # 1. Which gendered title to extract;
    # 2. whether or not to use the alternate gender if the primary is nil;
    # 3. how to order the returned list of titles (defaults to prestige);
    # 4. if needed to return the list in reverse order;
    # 5. and a generic yield mechanism to filter the list using a Proc.
    # See Awardable::InstanceMethods#awarded_titles documentation for details.
    titles = mal.awarded_titles
    puts "#{user.name}: #{titles.join ', '}"
    # => Malcolm Reynolds: Captain of the Serenity, Marksman

    # And for Zoe, who is the female First Officer:
    zoe = Character.new(:name => 'Zoe Warren')
    zoe.award_with!(:marksman)
    titles = zoe.awarded_titles(:gender => :female)
    puts "#{user.name}: #{titles.join ', '}"
    # => Zoe Warren: Markswoman

Extending the Models
====================

Extend the generated Award and Awardings models as you wish. For example,
we may want to associate our own icons to the Awards using Paperclip.

> script/generate migration add_icon_columns_to_award

The migration code:

    class AddIconColumnsToAward < ActiveRecord::Migration
      def self.up
        add_column :awards, :icon_file_name,    :string
        add_column :awards, :icon_content_type, :string
        add_column :awards, :icon_file_size,    :integer
        add_column :awards, :icon_updated_at,   :datetime
      end

      def self.down
        remove_column :awards, :icon_file_name
        remove_column :awards, :icon_content_type
        remove_column :awards, :icon_file_size
        remove_column :awards, :icon_updated_at
      end
    end

The icon is added to the Award model:

    class Award < ActiveRecord::Base
      includes Awardable::Award

      has_attached_file :icon,
          :styles => { :medium => "300x300>", :thumb => "100x100>" }
    end

Then create the controllers and views for the Awards as you like.

Let's add a user_id to the Awardings model so we know who granted the award.

> script/generate migration add_user_id_to_awardings

Then in the Awarding model:

    class Awarding < ActiveRecord::Base
      includes Awardable::Awarding
      belongs_to :user
    end

and when assigning an award:

> user.award_with!(award, :user => granting_user)

For each key in the options hash, we call "#{key}=" with the value if
the Awarding model responds to it.

The reciprocal relation in the User model that doesn't collide with
the built in `awardings` relation is left as an exercise to the reader.

A Note on Ranks and Titles
--------------------------

Note that sometimes titles are tightly coupled to an honorific that one
uses to address a person. For example, we would address Mal with the
rank of "Captain", in "Captain Malcolm Reynolds". But we don't implement
Rank in the Awardable system. The reason for this is that we believe
that determining what Rank a Awardable model has (or displays)
falls in the business logic side of things. What if the player that controls
Mal is the leader of his Guild (with the Guild Leader Award)?
This player may then display "Guild Leader" instead of the "Captain" Rank.

So Awardable doesn't enforce a particular method. Instead, it is up
to the developer to implement it. One suggested way is to:

1. Create a Rank model.
2. Create the has_one relation from the Character to Rank.
3. Extend the Award model to have a has_one relation to Rank.
4. Modify the the controller/views to allow a player to change the displayed
   Rank to any Rank available to him from his Awards.

Testing
=======
This library uses [Bundler](http://github.com/wycats/bundler) instead
of the base system's rubygems to pull in the requirements for tests.

> gem bundle
>
> rake spec
>
> rake features
>
> rake rcov

However, `rake rcov` requires rcov to be installed in the base system.

Note on Patches/Pull Requests
=============================
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a
  commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Authors
=======
* Benjamin Yu - <http://benjaminyu.org/>, <http://github.com/byu>

Copyright
=========

> Copyright 2009 Benjamin Yu
>
> Licensed under the Apache License, Version 2.0 (the "License");
> you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
> http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
> See the License for the specific language governing permissions and
> limitations under the License.
