require_relative "wicked_result"
require_relative "wicked_die"

class WickedPool
  attr_reader :dice, :result

  def initialize(dice:, randomizer: Random)
    self.dice = dice.map { |die| WickedDie.create(die: die, randomizer: randomizer) }
    self.randomizer = randomizer
  end

  def roll
    self.result = WickedResult.new(dice)
  end

  private

  attr_accessor :randomizer
  attr_writer :dice, :result
end
