class WickedResult
  include Comparable
  attr_reader :dice

  def initialize(dice)
    self.dice = dice
    dice.each(&:roll)
  end

  def values
    [unmodified_values.first + advantage_sum, unmodified_values[1..]].flatten
  end

  def result
    "#{ordered_values.join(", ")} (#{dice.sort.reverse.map(&:to_s).join(", ")})"
  end

  def advantage_dice
    dice.select(&:advantage)
  end

  def standard_dice
    dice.reject(&:advantage)
  end

  def unmodified_values
    standard_dice.map(&:value).sort.reverse
  end

  def advantage_sum
    advantage_dice.map(&:value).sum
  end

  def to_s
    result
  end

  def <=>(other)
    ordered_values <=> other.ordered_values
  end

  def ordered_values
    values.sort.reverse
  end

  private

  attr_writer :dice
end
