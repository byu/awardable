require 'awardable/grant'

module Awardable

  ##
  # The "Engine" that drives the checking and granting of awards.
  # It's main job is to (1) run the routes for checking if an observed
  # object produces any awards, and (2) possibly grant additional awards
  # because "just granted" awards complete the dependencies of a parent award.
  # As related to (2), it also will remove awardings of ancestor awards if
  # a just removed awarding breaks the dependency completion.
  #
  class Engine

    ##
    # @param routes the Rack::Mount::Routeset based routes. In reality, this
    #   is any callable object.
    #
    def initialize(routes)
      @routes = routes
    end

    ##
    # Runs the observed_object through a set of routes to see if there are
    # any awards to grant, then grants them. It also (if ancestry gem is
    # enabled for the Award class) to traverse the dependency tree to then
    # grant parent awards for a "Collective Achievement" type award.
    # Also, the created Awarding object will contain a reference to this
    # source object if the observed_object follows the ActiveRecord model,
    # and if the Awarding object includes the statement:
    #
    #   `belongs_to :source, :polymorphic => true`
    #
    # @param observed_object the source object to run a route against.
    # @return [Array<Grant>] a list of grants
    #
    def check_and_grant_awards!(observed_object)
      # for the observed object, let's see which awards it may grant
      # for each grantable award, we'll add the award using our
      # dependency graph award method: add_awards!
      # We'll return the list of all actual awarded adds, as stated by
      # add_awards!.
      added_grants = []
      candidate_grants = []
      status, headers, body = @routes.call :source => observed_object
      # We make sure we have a good status code
      return [] unless status == 200
      # Define a proc to do the adding of grants and parent candidates.
      do_grant = Proc.new { |grant|
        source = (
          observed_object.class.respond_to?(:base_class) and
          observed_object.respond_to?(:id)) ? observed_object : nil
        grant.awardable.award_with! grant.award, :source => source
        added_grants << grant
        # This is if we have ancestry enabled.
        if grant.award.respond_to?(:parent) and !grant.award.parent.nil?
          candidate_grants << Grant.new(grant.awardable, grant.award.parent)
        end
      }
      grants = Array(body)
      grants.each { |g| do_grant.call(g) }
      while !candidate_grants.empty?
        candidate = candidate_grants.shift
        do_grant.call(candidate) if(
          meets_requirements?(candidate) and
          !added_grants.include?(candidate.award))
      end
      return added_grants
    end

    ##
    # Removes an Awarding from an awardable. It will also will double check
    # if this removal invalidates awardings of parent awards.
    #
    # @param awardable the awardable to revoke
    # @param awarding the awarding object to revoke.
    #
    def remove_awarding!(awardable, awarding)
      current_award = awarding.award
      awardable = awarding.awardable
      awardable_id = awarding.awardable_id
      awardable_type = awarding.awardable_type
      awarding.delete
      return unless current_award.respond_to? :ancestors
      return if current_award.ancestors.empty?
      return unless meets_requirements? Grant.new(awardable, current_award)
      # The awardable did not meet the requirements for this award.
      # Thus this award and all ancestors of this award are voided.
      # We're going to delete all the awardings for these awards.
      # remove awardings where award in current_award.ancestors and is awardable
      Awarding.delete_all(
        'awardable_type' => awardable_type,
        'awardable_id' => awardable_id,
        'award_id' => current_award.ancestors)
    end

    private

    ##
    # Checks to see if an awardable's currently granted awards satisfies the
    # requirements of a "Collective Achievement" parent award.
    #
    def meets_requirements?(candidate)
      # NOTE: this is only called if we have awards that get awarded
      #   because of child awards. Ancestry gem required.
      # We get the set of awards granted to the current awardable.
      # We get the set of awards of all the current award's descendent awards.
      # If their intersection is equal to the set of descendent awards, then
      # we know that the current awardable object meets the requirements
      # to be automatically granted this current award.
      # NOTE: we must reload to pick up the saved Awarding rows.
      candidate.awardable.reload
      existing_awards = Array(candidate.awardable.awards)
      required_awards = Array(candidate.award.descendants).uniq
      return (required_awards & existing_awards) == required_awards
    end
  end
end
