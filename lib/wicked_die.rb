class WickedDie
  include Comparable
  def self.create(die:, randomizer: Random)
    if die == "A"
      AdvantageDie.new(randomizer: randomizer)
    else
      WickedDie.new(die: die, randomizer: randomizer)
    end
  end

  attr_reader :sides, :advantage, :value

  def <=>(other)
    if advantage?
      -1
    elsif other.advantage?
      +1
    else
      sides <=> other.sides
    end
  end

  def initialize(die:, randomizer:)
    self.sides = die[1..].to_i
    self.advantage = false
    self.randomizer = randomizer
    self.value = 0
  end

  def roll
    self.value = randomizer.rand(1..sides)
  end

  def to_s
    "d#{sides}: #{result}"
  end

  def advantage?
    advantage
  end

  def result
    value == 0 ? "unrolled" : value
  end

  private

  attr_accessor :randomizer
  attr_writer :sides, :advantage, :value
end

class AdvantageDie < WickedDie
  def initialize(randomizer:)
    self.advantage = true
    self.randomizer = randomizer
    self.sides = 6
    self.value = 0
  end

  def to_s
    "advantage: #{result}"
  end
end
