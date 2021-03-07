require "spec_helper"

RSpec.describe "Feature Tests" do
  describe "Valid die roll" do
    it "builds the dice pool and rolls the dice" do
      randomizer = class_double(Random)
      allow(randomizer).to receive(:rand).with(1..12).and_return(7)
      allow(randomizer).to receive(:rand).with(1..8).and_return(5)
      allow(randomizer).to receive(:rand).with(1..4).and_return(2)
      allow(randomizer).to receive(:rand).with(1..6).and_return(3)

      args = %w[d12 d8 d4 A]
      subject = WickedPool.new(dice: args, randomizer: randomizer)
      expect(subject.roll.to_s).to eq("Rolled 10, 5, 2 (d12: 7, d8: 5, d4: 2, advantage: 3)")
    end
  end
end
