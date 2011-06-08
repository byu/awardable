require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Awardable::Engine' do

  before do
    @award_1 = Award.create(
      :name => 'award1',
      :display_name => 'Award 1')
    @award_2 = Award.create(
      :name => 'award2',
      :display_name => 'Award 2')
    @award_3 = Award.create(
      :name => 'award3',
      :display_name => 'Award 3, parent of 4 and 5; ancestor of 6')
    @award_4 = Award.create(
      :name => 'award4',
      :display_name => 'Award 4, child of 3',
      :parent => @award_3)
    @award_5 = Award.create(
      :name => 'award5',
      :display_name => 'Award 5, child of 3',
      :parent => @award_3)
    @award_6 = Award.create(
      :name => 'award6',
      :display_name => 'Award 6, child of 5',
      :parent => @award_5)
    @awardable_1 = AwardableModel.create :name => 'user_name_1'
    @awardable_2 = InheritAwardableModel.create :name => 'user_name_2'
    @grant_1_1 = Awardable::Grant.new(@awardable_1, @award_1)
    @grant_2_2 = Awardable::Grant.new(@awardable_2, @award_2)
    @grant_2_3 = Awardable::Grant.new(@awardable_2, @award_3)
    @grant_2_4 = Awardable::Grant.new(@awardable_2, @award_4)
    @grant_2_5 = Awardable::Grant.new(@awardable_2, @award_5)
    @grant_2_6 = Awardable::Grant.new(@awardable_2, @award_6)
  end

  after do
    Awarding.delete_all
    Award.delete_all
    AwardableModel.delete_all
    ArObservedResource.delete_all
  end

  subject do
    builder = Awardable::Builder.new do |map|
      # We're building route maps with our stub AwardCheck model, which
      # just returns the grants we specify here.
      map.add_route(
        'AwardCheck',
        'success_check',
        { :relevant_id => 1 },
        @grant_1_1)
      map.add_route(
        'AwardCheck',
        'success_check',
        { :relevant_id => 2 },
        @grant_2_2)
      map.add_route(
        'AwardCheck',
        'success_check',
        { :relevant_id => 3 },
        @grant_2_4)
      map.add_route(
        'AwardCheck',
        'success_check',
        { :relevant_id => 4 },
        @grant_2_4,
        @grant_2_6)
      map.add_route(
        'AwardCheck',
        'success_check',
        { :relevant_id => 5 },
        @grant_1_1,
        @grant_2_2)
      map.add_route(
        'AwardCheck',
        'success_check',
        { :source_type => 'ArObservedResource' },
        @grant_1_1)
    end
    builder.build
  end

  it 'should not grant any awards because of no route' do
    subject.
      check_and_grant_awards!(ObservedResource.new(0)).should == []
    Awarding.count.should == 0
  end

  it 'should grant an award' do
    subject.
      check_and_grant_awards!(ObservedResource.new(1)).should == [@grant_1_1]
    Awarding.count.should == 1
    AwardableModel.find_by_name('user_name_1').awards.should == [@award_1]
    AwardableModel.find_by_name('user_name_2').awards.should == []
  end

  it 'should grant a different award' do
    subject.
      check_and_grant_awards!(ObservedResource.new(2)).should == [@grant_2_2]
    Awarding.count.should == 1
    AwardableModel.find_by_name('user_name_1').awards.should == []
    AwardableModel.find_by_name('user_name_2').awards.should == [@award_2]
  end

  it 'should not grant parent award' do
    subject.
      check_and_grant_awards!(ObservedResource.new(3)).should == [@grant_2_4]
    Awarding.count.should == 1
    AwardableModel.find_by_name('user_name_1').awards.should == []
    AwardableModel.find_by_name('user_name_2').awards.should == [@award_4]
  end

  it 'should grant parent award, even nested awards' do
    subject.
      check_and_grant_awards!(ObservedResource.new(4)).should =~ [
        @grant_2_3, @grant_2_4, @grant_2_5, @grant_2_6
      ]
    Awarding.count.should == 4
    AwardableModel.find_by_name('user_name_1').awards.should == []
    AwardableModel.find_by_name('user_name_2').awards.should =~ [
      @award_3, @award_4, @award_5, @award_6
    ]
  end

  it 'should grant awards to different awardables' do
    subject.
      check_and_grant_awards!(ObservedResource.new(5)).should =~ [
        @grant_1_1, @grant_2_2]
    Awarding.count.should == 2
    AwardableModel.find_by_name('user_name_1').awards.should == [@award_1]
    AwardableModel.find_by_name('user_name_2').awards.should == [@award_2]
  end

  it 'should cascade delete ancestors' do
    subject.
      check_and_grant_awards!(ObservedResource.new(4)).should =~ [
        @grant_2_3, @grant_2_4, @grant_2_5, @grant_2_6
      ]
    Awarding.count.should == 4
    AwardableModel.find_by_name('user_name_2').awards.should =~ [
      @award_3, @award_4, @award_5, @award_6
    ]

    # Now we want to delete award 6. This should also delete 3 and 5.
    # 6 is a child of 5; 5 is a child of 3.
    # Award4 is the only one left because it isn't an ancestor of 6.
    awarding = @award_6.awardings.first
    subject.remove_awarding!(@awardable_2, awarding)
    Awarding.count.should == 1
    Awarding.first.award.name.should == 'award4'
  end

  it 'should save sources of the award in awardings' do
    # This is an extension. This only works if the Awarding has a
    # has_many polymorphic field called source.
    observed_object = ArObservedResource.new
    subject.
      check_and_grant_awards!(observed_object).should == [@grant_1_1]
    Awarding.count.should == 1
    AwardableModel.find_by_name('user_name_1').awards.should == [@award_1]
    Awarding.first.source.should == observed_object
  end
end
