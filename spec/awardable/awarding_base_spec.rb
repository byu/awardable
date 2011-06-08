require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Awarding Base' do

  describe 'globally unique' do
    before do
      @award = Award.create(
        :name => 'award1',
        :display_name => 'Award 1',
        :once_global => true)
      @awardable_1 = AwardableModel.create :name => 'user_name_1'
      @awardable_2 = AwardableModel.create :name => 'user_name_2'
    end

    after do
      Awarding.delete_all
      Award.delete_all
      AwardableModel.delete_all
    end

    it 'should only allow a unique awarding' do
      @awardable_1.awards << @award
      result_1 = @awardable_1.save
      result_1.should be_true
      awarding = Awarding.new
      awarding.awardable = @awardable_2
      awarding.award = @award
      result_2 = awarding.save
      result_2.should be_false
    end
  end

  describe 'unique by instance' do
    before do
      @award = Award.create(
        :name => 'award1',
        :display_name => 'Award 1',
        :once_instance => true)
      @awardable_1 = AwardableModel.create :name => 'user_name_1'
      @awardable_2 = AwardableModel.create :name => 'user_name_2'
    end

    after do
      Awarding.delete_all
      Award.delete_all
      AwardableModel.delete_all
    end

    it 'should allow only one award per instance' do
      @awardable_1.awards << @award
      result = @awardable_1.save
      result.should be_true
      awarding = Awarding.new
      awarding.awardable = @awardable_1
      awarding.award = @award
      result = awarding.save
      result.should be_false

      @awardable_2.awards << @award
      result = @awardable_2.save
      result.should be_true
      awarding = Awarding.new
      awarding.awardable = @awardable_2
      awarding.award = @award
      result = awarding.save
      result.should be_false
    end
  end
end
