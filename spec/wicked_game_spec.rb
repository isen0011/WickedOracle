require "spec_helper"

RSpec.describe WickedGame do
  let(:game)     { described_class.new }
  let(:event)       { instance_double(Discordrb::Commands::CommandEvent) }
  let(:member)      { instance_double(Discordrb::Member) }
  let(:player_name) { "TestUser" }

  before do
    allow(event).to receive(:author).and_return(member)
    allow(member).to receive(:nickname).and_return(player_name)
  end

  describe ".roll" do
    it "rolls the dice given for the player" do
      randomizer = class_double(Random)
      allow(randomizer).to receive(:rand).with(1..12).and_return(7)
      allow(randomizer).to receive(:rand).with(1..8).and_return(5)
      allow(randomizer).to receive(:rand).with(1..4).and_return(2)
      allow(randomizer).to receive(:rand).with(1..6).and_return(3)

      args = %w[d12 d8 d4 A]
      subject = game.roll(args: args, event: event, randomizer: randomizer)
      expect(subject).to eq("TestUser rolled 10, 5, 2 (d12: 7, d8: 5, d4: 2, advantage: 3)")
    end

    it "stores the dice rolled for the player" do
      randomizer = class_double(Random)
      allow(randomizer).to receive(:rand).with(1..10).and_return(7)
      allow(randomizer).to receive(:rand).with(1..8).and_return(5)
      allow(randomizer).to receive(:rand).with(1..6).and_return(3)

      args = %w[d10 d8 A]
      game.roll(args: args, event: event, randomizer: randomizer)
      subject = game.show(args: args, event: event)
      expect(subject).to eq("TestUser's current pool is: d10: 7, d8: 5, advantage: 3")
    end

    it "can clear a player's pool" do
      args = %w[d10 d8 A]
      game.roll(args: args, event: event)
      expect(game.list(args: [], event: event)).to include("TestUser")
      game.clear(args: [], event: event)
      expect(game.list(args: [], event: event)).not_to include("TestUser")
    end

    it "can add or remove advantage dice to the roll"
  end
end