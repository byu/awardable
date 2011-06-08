require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ActsAsAwardable' do
  describe 'Awardable Class' do
    before do
      @awardable = AwardableModel.new :name => 'user_name_1'
    end

    it 'should have awards' do
      @awardable.should respond_to :awards
    end

    it 'should have an awards Array' do
      @awardable.awards.should be_an_instance_of Array
    end

    it 'should have awardings' do
      @awardable.should respond_to :awardings
    end

    it 'should have an awardings an Array' do
      @awardable.awards.should be_an_instance_of Array
    end

    it 'should have the find_awarded_with class method' do
      @awardable.class.should respond_to :find_awarded_with
    end

    it 'should have awards_set' do
      @awardable.should respond_to :awards_set
    end

    it 'should have unique_awards' do
      @awardable.should respond_to :unique_awards
    end

    it 'should have award_counts' do
      @awardable.should respond_to :award_counts
    end

    it 'should have award_with!' do
      @awardable.should respond_to :award_with!
    end

    it 'should have awarded_with?' do
      @awardable.should respond_to :awarded_with?
    end

    it 'should have awarded_titles' do
      @awardable.should respond_to :awarded_titles
    end

  end

  describe 'InheritAwardableModel Structure' do
    before do
      @awardable = AwardableModel.new :name => 'user_name_1'
    end

    it 'should have awards' do
      @awardable.should respond_to :awards
    end

    it 'should have an awards Array' do
      @awardable.awards.should be_an_instance_of Array
    end

    it 'should have awardings' do
      @awardable.should respond_to :awardings
    end

    it 'should have an awardings an Array' do
      @awardable.awards.should be_an_instance_of Array
    end

    it 'should have the find_awarded_with class method' do
      @awardable.class.should respond_to :find_awarded_with
    end

    it 'should have awards_set' do
      @awardable.should respond_to :awards_set
    end

    it 'should have unique_awards' do
      @awardable.should respond_to :unique_awards
    end

    it 'should have award_counts' do
      @awardable.should respond_to :award_counts
    end

    it 'should have award_with!' do
      @awardable.should respond_to :award_with!
    end

    it 'should have awarded_with?' do
      @awardable.should respond_to :awarded_with?
    end

    it 'should have awarded_titles' do
      @awardable.should respond_to :awarded_titles
    end
  end

  describe 'Awardable.find_awarded_with' do
    before do
      @award = Award.create(
        :name => 'award1',
        :display_name => 'Award 1')
      @award2 = Award.create(
        :name => 'award2',
        :display_name => 'Award 2')
      @awardable = AwardableModel.create :name => 'user_name_1'
      @awardable.awards << @award
      @awardable.save
    end

    after do
      Awarding.delete_all
      Award.delete_all
      AwardableModel.delete_all
    end

    it 'should find the awardable, using a symbol' do
      results = AwardableModel.find_awarded_with :award1
      results.should eql [@awardable]
    end

    it 'should find the awardable, using Award' do
      results = AwardableModel.find_awarded_with @award
      results.should eql [@awardable]
    end

    it 'should not find the awardable, using a symbol' do
      results = AwardableModel.find_awarded_with :award_not_exist
      results.should be_empty
    end

    it 'should not find the awardable, using Award' do
      results = AwardableModel.find_awarded_with @award2
      results.should be_empty
    end
  end

  describe 'Awardable Instance' do
    before do
      @award = Award.create(
        :name => 'award1',
        :display_name => 'Award 1')
      @other_award = Award.create(
        :name => 'award2',
        :display_name => 'Award 2')
      @awardable = AwardableModel.create :name => 'user_name_1'
      @awardable.awards << @award
      @awardable.save
      @awardable.awards << @award
      @awardable.save
    end

    after do
      Awarding.delete_all
      Award.delete_all
      AwardableModel.delete_all
    end

    it 'should have two Awards' do
      @awardable.awards.should have(2).awards
    end

    it 'should have two Awardings' do
      @awardable.awards.should have(2).awardings
    end

    it 'should have one Award in the array from unique_awards' do
      @awardable.should have(1).unique_awards
    end

    it 'should have one Award in the set from awards_set' do
      @awardable.should have(1).awards_set
    end

    it 'should have 2 count for added award' do
      @awardable.award_counts.should have_key('award1')
      @awardable.award_counts['award1'].should eql 2
    end

    it 'should detect awarded_with? Award using #to_s' do
      @awardable.awarded_with?(:award1).should be_true
    end

    it 'should detect awarded_with? using Award object' do
      @awardable.awarded_with?(@award).should be_true
    end

    it 'should detect awarded_with? using Award in Set' do
      @awardable.awarded_with?(Set.new([@award])).should be_true
    end

    it 'should detect awarded_with? using Award in Array' do
      @awardable.awarded_with?([@award]).should be_true
    end

    it 'should detect awarded_with? using #to_s in Set' do
      @awardable.awarded_with?(Set.new([:award1])).should be_true
    end

    it 'should detect awarded_with? using #to_s in Array' do
      @awardable.awarded_with?([:award1]).should be_true
    end

    it 'should detect awarded_with? using #to_s in Set nested in Array' do
      @awardable.awarded_with?([Set.new([:award1])]).should be_true
    end

    it 'should NOT detect awarded_with? Award using #to_s' do
      @awardable.awarded_with?(:award_non_exist).should be_false
    end

    it 'should NOT detect awarded_with? using other Award object' do
      @awardable.awarded_with?(@other_award).should be_false
    end

    it 'should NOT detect awarded_with? using Award in Set' do
      @awardable.awarded_with?(Set.new([@other_award])).should be_false
    end

    it 'should NOT detect awarded_with? using Award in Array' do
      @awardable.awarded_with?([@other_award]).should be_false
    end

    it 'should NOT detect awarded_with? using #to_s in Set' do
      @awardable.awarded_with?(Set.new([:award_non_exist])).should be_false
    end

    it 'should NOT detect awarded_with? using #to_s in Array' do
      @awardable.awarded_with?([:award_non_exist]).should be_false
    end

    it 'should NOT detect awarded_with? using #to_s in Set nested in Array' do
      @awardable.awarded_with?([Set.new([:non_exist_award])]).should be_false
    end
  end

  describe 'Awardable Instance award_with!' do
    before do
      @awardable = AwardableModel.new :name => 'user_name_1'
      @award1 = Award.create(
        :name => 'award1',
        :display_name => 'Award 1')
    end

    after do
      Awarding.delete_all
      Award.delete_all
      AwardableModel.delete_all
    end

    it 'should be able to be awarded award1, using a symbol' do
      @awardable.award_with!(:award1).should be_true
      @awardable.awards.should include(@award1)
    end

    it 'should be able to be awarded award1, using a Award object' do
      @awardable.award_with!(@award1).should be_true
      @awardable.awards.should include(@award1)
    end

    it 'should NOT be able to be awarded nonexisted Award, using a symbol' do
      @awardable.award_with!(:award_non_exist).should be_false
      @awardable.awards.should_not include(@award1)
    end

    it 'should NOT be able to be awarded nil' do
      @awardable.award_with!(nil).should be_false
      @awardable.awards.should_not include(@award1)
    end

    it 'should assign Awardings attributes using options' do
      @awardable.award_with!(:award1, :some_option => 'DATA').should be_true
      @awardable.awardings.first.some_option.should eql('DATA')
    end
  end

  describe 'Awardable awarded_titles' do
    before do
      @name1 = 'crown_knight'
      @mtitle1 = 'Defender of the Crown'
      @award1 = Award.create(
        :name => @name1,
        :display_name => "Knight's Chalice",
        :masculine_title => @mtitle1,
        :prestige => 1)
      @mtitle2 = 'Grand Duke of Luxembourg'
      @ftitle2 = 'Grand Duchess of Luxembourg'
      @award2 = Award.create(
        :name => 'ruler_of_luxembourg',
        :display_name => 'Crown of Luxembourg',
        :masculine_title => @mtitle2,
        :feminine_title => @ftitle2,
        :prestige => 2)
      @ftitle3 = 'Doctor of Fine Arts'
      @award3 = Award.create(
        :name => 'phd_fine_arts',
        :display_name => 'Fine Arts PHD',
        :feminine_title => @ftitle3)
      @awardable = AwardableModel.create :name => 'user_name_1'
      @awardable.awards << @award1
      @awardable.save
      @awardable.awards << @award2
      @awardable.save
      @awardable.awards << @award3
      @awardable.save
    end

    after do
      Awarding.delete_all
      Award.delete_all
      AwardableModel.delete_all
    end

    it 'should handle duplicate awardings' do
      @awardable.awards << @award1
      @awardable.save
      @awardable.awards << @award2
      @awardable.save
      @awardable.awards << @award3
      @awardable.save
      @awardable.awarded_titles.should eql([
        @mtitle2,
        @mtitle1])
    end

    it 'should be masculine only' do
      @awardable.awarded_titles.should eql([
        @mtitle2,
        @mtitle1])
    end

    it 'should be feminine only' do
      @awardable.awarded_titles(:gender => :female).should eql([
        @ftitle2,
        @ftitle3])
    end

    it 'should be either masculine or feminine, default masculine' do
      @awardable.awarded_titles(:alt_gender_ok => true).should eql([
        @mtitle2,
        @mtitle1,
        @ftitle3])
    end

    it 'should be either masculine or feminine, default feminine' do
      @awardable.awarded_titles(
          :gender => :female,
          :alt_gender_ok => true).should eql([
        @ftitle2,
        @mtitle1,
        @ftitle3])
    end

    it 'should be masculine only, reversed order' do
      @awardable.awarded_titles(:reverse => true).should eql([
        @mtitle1,
        @mtitle2])
    end

    it 'should be feminine only, reversed order' do
      @awardable.awarded_titles(
          :gender => :female,
          :reverse => true).should eql([
        @ftitle3,
        @ftitle2])
    end

    it 'should be either masculine or feminine, reversed, default masculine' do
      @awardable.awarded_titles(
          :alt_gender_ok => true,
          :gender => :male).should eql([
        @mtitle2,
        @mtitle1,
        @ftitle3])
    end

    it 'should be either masculine or feminine, reversed, default feminine' do
      @awardable.awarded_titles(
          :gender => :female,
          :alt_gender_ok => true).should eql([
        @ftitle2,
        @mtitle1,
        @ftitle3])
    end

    it 'should be order descending by name, masculine only' do
      @awardable.awarded_titles(
          :gender => :male,
          :order_by => :display_name).should eql([
        @mtitle1,
        @mtitle2])
    end

    it 'should be order ascending by name, masculine only' do
      @awardable.awarded_titles(
          :gender => :male,
          :reverse => true,
          :order_by => :display_name).should eql([
        @mtitle2,
        @mtitle1])
    end

    it 'should be order ascending by name, both genders, default female' do
      @awardable.awarded_titles(
          :gender => :female,
          :alt_gender_ok => true,
          :reverse => true,
          :order_by => :display_name).should eql([
        @ftitle2,
        @ftitle3,
        @mtitle1])
    end

    it 'should be both genders, default feminine and filter with proc' do
      @awardable.awarded_titles(
          :gender => :female,
          :alt_gender_ok => true) do |award|
            award.name == @name1
          end.should eql([
        @ftitle2,
        @ftitle3])
    end
  end
end
