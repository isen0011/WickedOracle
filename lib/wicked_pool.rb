require_relative "wicked_result"
require_relative "wicked_die"

class WickedPool
  attr_reader :dice, :result, :player

  def initialize(dice:, player: "", randomizer: Random)
    self.dice = dice.map { |die| WickedDie.create(die: die, randomizer: randomizer) }
    self.randomizer = randomizer
    self.player = player
  end

  def roll
    self.result = WickedResult.new(dice)
    self
  end

  def to_s
    "#{player_display} #{result}"
  end

  private

  def player_display
    if player
      "#{player} rolled"
    else
      "Rolled"
    end
  end

  attr_accessor :randomizer
  attr_writer :dice, :result, :player
end
