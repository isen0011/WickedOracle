require "spec_helper"

RSpec.describe WickedPool do
  describe ".initialize" do
    context "with just two dice" do
      it "builds a pool with valid dice" do
        args = %w[d12 d8]
        subject = described_class.new(dice: args)
        expect(subject.dice.count).to eq 2
      end
    end
  end

  describe "#roll" do
    context "with just two dice" do
      it "rolls the dice and returns a result object" do
        args = %w[d12 d8]
        subject = described_class.new(dice: args)
        expect(subject.roll).to be_instance_of(WickedPool)
        expect(subject.result).to be_instance_of(WickedResult)
      end
    end

    describe "#result" do
      context "with just two dice" do
        it "shows the result of the previous roll" do
          args = %w[d12 d8]
          subject = described_class.new(dice: args)
          roll = subject.roll.result
          expect(subject.result).to equal(roll)
        end
      end
    end

    describe "#to_s" do
      context "with an unrolled advantage die" do
        it "shows the unrolled die, but doesn't roll it" do
          args = %w[d12 d8]
          subject = described_class.new(dice: args)
          subject.roll
          subject.adjust_advantage("+")
          expect(subject.to_s).to match(/\d+, \d+ \(d12: \d+, d8: \d+, advantage: unrolled\)/)
        end
      end
    end

    describe "#dice_list" do
      context "with just two dice" do
        it "just shows the dice in the pool, not the result" do
          args = %w[d12 d8]
          subject = described_class.new(dice: args)
          expect(subject.dice_list).to eq("d12: unrolled, d8: unrolled")
        end
      end
    end

    describe "#adjust_advantage" do
      context "with just two dice" do
        it "adds an advantage to the die pool" do
          args = %w[d12 d8]
          subject = described_class.new(dice: args)
          expect(subject.adjust_advantage("+")).to eq("Added an advantage die")
          expect(subject.dice_list).to eq("d12: unrolled, d8: unrolled, advantage: unrolled")
        end
      end

      context "with an advantage die" do
        it "removes an advantage from the die pool" do
          args = %w[d12 d8 A]
          subject = described_class.new(dice: args)
          expect(subject.adjust_advantage("-")).to eq("Removed an advantage die")
          expect(subject.dice_list).to eq("d12: unrolled, d8: unrolled")
        end

        it "adds a second advantage to the die pool" do
          args = %w[d12 d8 A]
          subject = described_class.new(dice: args)
          expect(subject.adjust_advantage("+")).to eq("Added an advantage die")
          expect(subject.dice_list).to eq("d12: unrolled, d8: unrolled, advantage: unrolled, advantage: unrolled")
        end
      end

      context "with two advantage dice" do
        it "removes an advantage from the die pool" do
          args = %w[d12 d8 A A]
          subject = described_class.new(dice: args)
          expect(subject.adjust_advantage("-")).to eq("Removed an advantage die")
          expect(subject.dice_list).to eq("d12: unrolled, d8: unrolled, advantage: unrolled")
        end
      end
    end
  end
end
