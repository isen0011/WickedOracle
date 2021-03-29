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

  describe "#list" do
    it "correctly displays pools with unrolled dice" do
      randomizer = class_double(Random)
      allow(randomizer).to receive(:rand).with(1..12).and_return(7)
      allow(randomizer).to receive(:rand).with(1..4).and_return(2)

      roll_args = %w[d12 d4]
      game.roll(args: roll_args, event: event, randomizer: randomizer)

      adv_args = %w[+]
      game.adv(event: event, args: adv_args)

      subject = game.list(event: event, args: [])

      expect(subject).to eq("TestUser rolled 7, 2 (d12: 7, d4: 2, advantage: unrolled)")
    end

    it "displays players in order of their highest roll" do
      first_players_dice = %w[d12 d8 d10]
      first_players_name = %w[First player]
      first_players_args = first_players_name + first_players_dice
      first_players_rolls = class_double(Random)
      allow(first_players_rolls).to receive(:rand).with(1..12).and_return(7)
      allow(first_players_rolls).to receive(:rand).with(1..10).and_return(7)
      allow(first_players_rolls).to receive(:rand).with(1..8).and_return(7)

      game.roll(args: first_players_args, event: event, randomizer: first_players_rolls)

      second_players_dice = %w[d10 d8]
      second_players_name = %w[Secondus playerous]
      second_players_args = second_players_name + second_players_dice
      second_players_rolls = class_double(Random)
      allow(second_players_rolls).to receive(:rand).with(1..10).and_return(8)
      allow(second_players_rolls).to receive(:rand).with(1..8).and_return(2)

      game.roll(args: second_players_args, event: event, randomizer: second_players_rolls)

      third_players_dice = %w[d10 d8 A]
      third_players_name = %w[Triad]
      third_players_args = third_players_name + third_players_dice
      third_players_rolls = class_double(Random)
      allow(third_players_rolls).to receive(:rand).with(1..10).and_return(6)
      allow(third_players_rolls).to receive(:rand).with(1..8).and_return(6)
      allow(third_players_rolls).to receive(:rand).with(1..6).and_return(2)

      game.roll(args: third_players_args, event: event, randomizer: third_players_rolls)

      fourth_players_dice = %w[d10 d8 d4]
      fourth_players_name = %w[Fourthy]
      fourth_players_args = fourth_players_name + fourth_players_dice
      fourth_players_rolls = class_double(Random)
      allow(fourth_players_rolls).to receive(:rand).with(1..10).and_return(8)
      allow(fourth_players_rolls).to receive(:rand).with(1..8).and_return(6)
      allow(fourth_players_rolls).to receive(:rand).with(1..4).and_return(1)

      game.roll(args: fourth_players_args, event: event, randomizer: fourth_players_rolls)

      subject = game.list(args: [], event: event)

      expect(subject).to eq(<<~LISTING.chomp
        Fourthy rolled 8, 6, 1 (d10: 8, d8: 6, d4: 1)
        Triad rolled 8, 6 (d10: 6, d8: 6, advantage: 2)
        Secondus playerous rolled 8, 2 (d10: 8, d8: 2)
        First player rolled 7, 7, 7 (d12: 7, d10: 7, d8: 7)
      LISTING
                           )
    end
  end

  describe "#roll" do
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

    it "can roll for a player other than the current user" do
      args = %w[Other Character with de Long Name d10 d8 A]
      subject = game.roll(args: args, event: event)
      expect(subject).to start_with("Other Character with de Long Name rolled")
      expect(subject).to include("d10")
      expect(subject).to include("d8")
      expect(subject).to include("advantage")
    end

    it "can re-roll for a player other than the current user" do
      dice_args = %w[Other Character with de Long Name d10 d8 A]
      game.roll(args: dice_args, event: event)
      name_args = %w[Other Character with de Long Name]
      subject = game.roll(args: name_args, event: event)

      expect(subject).to start_with("Other Character with de Long Name rolled")
      expect(subject).to include("d10")
      expect(subject).to include("d8")
      expect(subject).to include("advantage")
    end

  end

  describe "#adv" do
    it "can add advantage dice to the current player's roll" do
      args = %w[d10 d8]
      game.roll(args: args, event: event)
      expect(game.adv(args: ["+"], event: event)).to eq("TestUser: Added an advantage die")
      expect(game.show(args: [], event: event)).to match(/TestUser's current pool is: d10: \d+, d8: \d, advantage: unrolled/)
    end

    it "can remove advantage dice from the current player's roll" do
      args = %w[d10 d8 A]
      game.roll(args: args, event: event)
      expect(game.adv(args: ["-"], event: event)).to eq("TestUser: Removed an advantage die")
      expect(game.show(args: [], event: event)).to match(/TestUser's current pool is: d10: \d+, d8: \d/)
    end

    it "can add advantage dice to a given character's roll" do
      args = %w[Some other Character d10 d8]
      game.roll(args: args, event: event)
      expect(game.adv(args: %w[Some other Character +], event: event)).to eq("Some other Character: Added an advantage die")
      expect(game.show(args: %w[Some other Character], event: event)).to match(/Some other Character's current pool is: d10: \d+, d8: \d, advantage: unrolled/)
    end

    it "can remove advantage dice from a given character's roll" do
      args = %w[Some other Character d10 d8 A]
      game.roll(args: args, event: event)
      expect(game.adv(args: %w[Some other Character -], event: event)).to eq("Some other Character: Removed an advantage die")
      expect(game.show(args: %w[Some other Character], event: event)).to match(/Some other Character's current pool is: d10: \d+, d8: \d/)
    end

    it "can add a second advantage die" do
      args = %w[d10 d8 A]
      game.roll(args: args, event: event)
      expect(game.adv(args: ["+"], event: event)).to eq("TestUser: Added an advantage die")
      expect(game.show(args: [], event: event)).to match(/TestUser's current pool is: d10: \d+, d8: \d, advantage: \d, advantage: unrolled/)
    end

    it "can remove one advantage die without removing the second if they have two" do
      args = %w[d10 d8 A A]
      game.roll(args: args, event: event)
      expect(game.adv(args: ["-"], event: event)).to eq("TestUser: Removed an advantage die")
      expect(game.show(args: [], event: event)).to match(/TestUser's current pool is: d10: \d+, d8: \d, advantage: \d/)
    end
  end

  describe "#show" do
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

    it "can show the pool for a player other than the current user" do
      args = %w[Other Character with de Long Name d10 d8 A]
      game.roll(args: args, event: event)
      subject = game.show(event: event, args: %w[Other Character with de Long Name])
      expect(subject).to start_with("Other Character with de Long Name's current pool is:")
      expect(subject).to include("d10")
      expect(subject).to include("d8")
      expect(subject).to include("advantage")
    end
  end

  describe "#clear" do
    it "can clear a player's pool" do
      args = %w[d10 d8 A]
      game.roll(args: args, event: event)
      expect(game.list(args: [], event: event)).to include("TestUser")
      game.clear(args: [], event: event)
      expect(game.list(args: [], event: event)).not_to include("TestUser")
    end

    it "can clear the pool for a player other than the current user" do
      name_args = %w[Other Character with de Long Name]
      args = %w[Other Character with de Long Name d10 d8 A]
      game.roll(args: args, event: event)
      expect(game.list(args: [], event: event)).to include("Other Character with de Long Name")
      game.clear(args: name_args, event: event)
      expect(game.list(args: [], event: event)).not_to include("Other Character with de Long Name")
    end
  end
end
