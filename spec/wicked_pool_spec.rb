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
        expect(subject.roll).to be_instance_of(WickedResult)
      end
    end

    describe "#result" do
      context "with just two dice" do
        it "shows the result of the previous roll" do
          args = %w[d12 d8]
          subject = described_class.new(dice: args)
          roll = subject.roll
          expect(subject.result).to equal(roll)
        end
      end
    end
  end
end
