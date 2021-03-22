require "spec_helper"

RSpec.describe WickedGame do
  let(:game) { described_class.new }
  let(:event) { instance_double(Discordrb::Commands::CommandEvent) }
  let(:member) { instance_double(Discordrb::Member) }
  let(:player_name) { "TestUser" }

  before do
    allow(event).to receive(:author).and_return(member)
    allow(member).to receive(:nickname).and_return(player_name)
  end

  describe "#COMMANDS" do
    let(:subject) { described_class::COMMANDS }
    it "returns an array of symbols" do
      expect(subject).to be_a(Array)
      expect(subject.sample).to be_a(Symbol)
    end
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
  end

  describe "#advantage" do
    it "can add advantage dice to the current player's roll" do
      args = %w[d10 d8]
      game.roll(args: args, event: event)
      expect(game.advantage(args: ["+"], event: event)).to eq("TestUser: Added an advantage die")
      expect(game.show(args: [], event: event)).to match(/TestUser's current pool is: d10: \d+, d8: \d, advantage: unrolled/)
    end

    it "can remove advantage dice from the current player's roll" do
      args = %w[d10 d8 A]
      game.roll(args: args, event: event)
      expect(game.advantage(args: ["-"], event: event)).to eq("TestUser: Removed an advantage die")
      expect(game.show(args: [], event: event)).to match(/TestUser's current pool is: d10: \d+, d8: \d/)
    end

    it "can add advantage dice to a given character's roll" do
      args = %w[Some other Character d10 d8]
      game.roll_for(args: args, event: event)
      expect(game.advantage(args: %w[Some other Character +], event: event)).to eq("Some other Character: Added an advantage die")
      expect(game.show_for(args: %w[Some other Character], event: event)).to match(/Some other Character's current pool is: d10: \d+, d8: \d, advantage: unrolled/)
    end

    it "can remove advantage dice from a given character's roll" do
      args = %w[Some other Character d10 d8 A]
      game.roll_for(args: args, event: event)
      expect(game.advantage(args: %w[Some other Character -], event: event)).to eq("Some other Character: Removed an advantage die")
      expect(game.show_for(args: %w[Some other Character], event: event)).to match(/Some other Character's current pool is: d10: \d+, d8: \d/)
    end

    it "can add a second advantage die" do
      args = %w[d10 d8 A]
      game.roll(args: args, event: event)
      expect(game.advantage(args: ["+"], event: event)).to eq("TestUser: Added an advantage die")
      expect(game.show(args: [], event: event)).to match(/TestUser's current pool is: d10: \d+, d8: \d, advantage: \d, advantage: unrolled/)
    end

    it "can remove one advantage die without removing the second if they have two" do
      args = %w[d10 d8 A A]
      game.roll(args: args, event: event)
      expect(game.advantage(args: ["-"], event: event)).to eq("TestUser: Removed an advantage die")
      expect(game.show(args: [], event: event)).to match(/TestUser's current pool is: d10: \d+, d8: \d, advantage: \d/)
    end
  end

  describe "#roll_for" do
    it "can roll for a player other than the current user" do
      args = %w[Other Character with de Long Name d10 d8 A]
      subject = game.roll_for(args: args, event: event)
      expect(subject).to start_with("Other Character with de Long Name rolled")
      expect(subject).to include("d10")
      expect(subject).to include("d8")
      expect(subject).to include("advantage")
    end

    it "will reroll if the player already has a pool" do
      args = %w[Other Character with de Long Name d10 d8 A]
      game.roll_for(args: args, event: event)
      subject = game.roll_for(args: %w[Other Character with de Long Name], event: event)
      expect(subject).to start_with("Other Character with de Long Name rolled")
      expect(subject).to include("d10")
      expect(subject).to include("d8")
      expect(subject).to include("advantage")
    end
  end

  describe "#show-for" do
    it "can show the pool for a player other than the current user" do
      args = %w[Other Character with de Long Name d10 d8 A]
      game.roll_for(args: args, event: event)
      subject = game.show_for(event: event, args: %w[Other Character with de Long Name])
      expect(subject).to start_with("Other Character with de Long Name's current pool is:")
      expect(subject).to include("d10")
      expect(subject).to include("d8")
      expect(subject).to include("advantage")
    end
  end

  describe "#clear-for" do
    it "can clear the pool for a player other than the current user" do
      name_args = %w[Other Character with de Long Name]
      args = %w[Other Character with de Long Name d10 d8 A]
      game.roll_for(args: args, event: event)
      expect(game.list(args: [], event: event)).to include("Other Character with de Long Name")
      game.clear_for(args: name_args, event: event)
      expect(game.list(args: [], event: event)).not_to include("Other Character with de Long Name")
    end
  end
end
