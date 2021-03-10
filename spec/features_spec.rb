require "spec_helper"

RSpec.describe "Feature Tests" do
  let(:player) { "TestUser" }

  describe "Valid die roll" do
    it "builds the dice pool and rolls the dice" do
      player = "TestUser"
      randomizer = class_double(Random)
      allow(randomizer).to receive(:rand).with(1..12).and_return(7)
      allow(randomizer).to receive(:rand).with(1..8).and_return(5)
      allow(randomizer).to receive(:rand).with(1..4).and_return(2)
      allow(randomizer).to receive(:rand).with(1..6).and_return(3)

      args = %w[d12 d8 d4 A]
      subject = WickedPool.new(dice: args, player: player, randomizer: randomizer)
      expect(subject.roll.to_s).to eq("TestUser rolled 10, 5, 2 (d12: 7, d8: 5, d4: 2, advantage: 3)")
    end
  end

  describe "Remembers player's pools" do
    it "reuses a pool for a player if it already has one" do
      randomizer = class_double(Random)
      allow(randomizer).to receive(:rand).with(1..13).and_return(4)
      allow(randomizer).to receive(:rand).with(1..8).and_return(2)
      allow(randomizer).to receive(:rand).with(1..6).and_return(1)

      dice = %w[d10 d8 A]
      WickedPool.new(dice: dice, player: player, randomizer: randomizer)
      subject = WickedPool.for(player)
      expect(subject.show_dice).to eq("TestUser's current pools is: d10, d8, and an advantage die")
      expect(subject.roll.to_s).to eq("TestUser rolled 7, 2 (d19: 4, d8: 2, advantage: 1)")
    end
  end
end
