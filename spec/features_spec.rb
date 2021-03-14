require "spec_helper"

RSpec.describe "Feature Tests" do
  let(:player) { "TestUser" }

  describe "Remembers player's pools" do
    let(:game)    { WickedGame.new }
    let(:event)   { instance_double(Discordrb::Commands::CommandEvent) }
    let(:member)  { instance_double(Discordrb::Member) }

    before do
      allow(event).to receive(:author).and_return(member)
      allow(member).to receive(:nickname).and_return("TestUser")
    end

    it "reuses a pool for a player if it already has one" do
      pending
      randomizer = class_double(Random)
      allow(randomizer).to receive(:rand).with(1..10).and_return(4)
      allow(randomizer).to receive(:rand).with(1..8).and_return(2)
      allow(randomizer).to receive(:rand).with(1..6).and_return(1)

      args = %w[d10 d8 A]
      game.roll(args: args, event: event)
      subject = game.roll(args: [], event: event, randomizer: randomizer)
      expect(subject).to eq("TestUser rolled 7, 2 (d10: 4, d8: 2, advantage: 1)")
    end
  end

  describe "Started and ending conflict" do
    it "will remember dice within the conflict" do
      pending
      expect(game.start_conflict).to eq("Conflict started!")
      expect(game.list).to eq("No current players in conflict")
      expect(game.join(args: %w[d8 d4], player: "Player1")).to eq("Player1 joined the conflict with pool: d8, d4")
      expect(game.join(args: %w[d12 d8 A], player: "Player2")).to eq("Player2 joined the conflict with pool: d12, d8, and an advantage die")
      expect(game.list).to eq("Current players:\nPlayer1's current pool is: d8, d4\nPlayer2's current pool is: d12, d8, and an advantage die")
      expect(game.end_conflict).to eq("Conflict ended!")
      expect(game.list).to eq("No current conflict... use /start_conflict to start a conflict")
    end

    it "will remember the last rolls of the players" do
      pending
      game.start_conflict
      randomizer1 = class_double(Random)
      allow(randomizer1).to receive(:rand).with(1..10).and_return(4)
      allow(randomizer1).to receive(:rand).with(1..8).and_return(2)
      allow(randomizer1).to receive(:rand).with(1..6).and_return(1)

      args = %w[d10 d8 A]
      game.roll(args: args, player: "Player1", randomizer: randomizer1)

      randomizer2 = class_double(Random)
      allow(randomizer2).to receive(:rand).with(1..12).and_return(7)
      allow(randomizer2).to receive(:rand).with(1..4).and_return(4)
      allow(randomizer2).to receive(:rand).with(1..8).and_return(2)

      args = %w[d12 d4 d8]
      game.roll(args: args, player: "Player2", randomizer: randomizer2)

      expect(game.list).to eq("Current players:\nPlayer2: 7, 4, 2 (d12: 7, d8:2, d4: 4)\nPlayer1: 5, 2 (d1O: 4, d8: 2, advantage: 1)")
    end
  end
end
