require_relative "wicked_result"
require_relative "wicked_die"

class WickedPool
  include Comparable
  attr_reader :dice, :result

  def initialize(dice:, randomizer: Random)
    self.dice = dice.map { |die| WickedDie.create(die: die, randomizer: randomizer) }
    self.randomizer = randomizer
  end

  def roll
    self.result = WickedResult.new(dice)
    self
  end

  def to_s
    result.to_s
  end

  def dice_list
    dice.map(&:to_s).join(", ")
  end

  def adjust_advantage(adjustment)
    if adjustment == "+"
      dice.push(WickedDie.create(die: "A"))
      "Added an advantage die"
    else
      remove_advantage
    end
  end

  def <=>(other)
    result <=> other.result
  end

  private

  attr_accessor :randomizer
  attr_writer :dice, :result

  def remove_advantage
    if has_advantage?
      dice.delete_at(first_advantage_index)
      "Removed an advantage die"
    else
      "No advantage die to remove"
    end
  end

  def has_advantage?
    dice.any? { |die| die.advantage? }
  end

  def first_advantage_index
    dice.find_index { |die| die.advantage? }
  end
end
