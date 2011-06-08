module Awardable

  ##
  # A simple data object to pair an Awardable with and Award.
  # It is used to signify an actual granted award, or an awarding
  # pair that we want to verify for "Collective Achievements"
  #
  class Grant
    attr_accessor :awardable, :award

    def initialize(awardable, award)
      @awardable = awardable
      @award = award
    end

    def ==(other)
      if other.respond_to?(:awardable) and other.respond_to?(:award)
        self.awardable == other.awardable and self.award == other.award
      else
        false
      end
    end
  end
end
