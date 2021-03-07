require "spec_helper"

RSpec.describe WickedDie do
  let(:random_result) { 3 }
  let(:randomizer) { class_double(Random) }

  describe "Dice creation" do

    before do
      allow(randomizer).to receive(:rand).with(1..expected_sides).and_return(random_result)
    end

    %w[d4 d6 d8 d10 d12].each do |die|
      context "when using a #{die} die" do
        let(:subject) { described_class.create(die: die, randomizer: randomizer) }
        let(:expected_sides) { die[1..].to_i }

        describe ".create" do
          it "correctly creates the die" do
            expect(subject.sides).to eq(expected_sides)
          end

          it "has the advantage flag not set" do
            expect(subject.advantage).to be_falsey
          end
        end

        describe "#result" do
          it "returns unrolled when it hasn't been rolled yet" do
            expect(subject.result).to eq("unrolled")
          end

          it "uses a randomizer to return the result if it is rolled" do
            subject.roll
            expect(subject.result).to eq(random_result)
          end
        end

        describe "#to_s" do
          context "when the die hasn't been rolled yet" do
            it "returns the die with an unrolled value" do
              expect(subject.to_s).to eq("#{die}: unrolled")
            end
          end

          context "when the die has been rolled" do
            it "returns the die type and the value" do
              subject.roll
              expect(subject.to_s).to eq("#{die}: #{random_result}")
            end
          end
        end
      end
    end

    context "when using an advantage die" do
      let(:expected_sides) { 6 }
      let(:subject) { described_class.create(die: "A", randomizer: randomizer) }

      describe ".create" do
        it "has 6 sides" do
          expect(subject.sides).to eq(6)
        end

        it "has the advantage flag set" do
          expect(subject.advantage).to be_truthy
        end
      end

      describe ".result" do
        it "returns unrolled when it hasn't been rolled yet" do
          expect(subject.result).to eq("unrolled")
        end

        it "uses a randomizer to return the result if it is rolled" do
          subject.roll
          expect(subject.result).to eq(random_result)
        end
      end

      describe "#to_s" do
        context "when the die hasn't been rolled yet" do
          it "returns the die with an unrolled value" do
            expect(subject.to_s).to eq("advantage: unrolled")
          end
        end

        context "when the die has been rolled" do
          it "returns the die type and the value" do
            subject.roll
            expect(subject.to_s).to eq("advantage: #{random_result}")
          end
        end
      end
    end
  end

  describe "Sorting" do
    let(:d4) { WickedDie.create(die: "d4", randomizer: randomizer) }
    let(:d10) { WickedDie.create(die: "d10", randomizer: randomizer) }
    let(:advantage) { WickedDie.create(die: "A", randomizer: randomizer) }

    it "sorts dice by size" do
      expect(d4).to be < d10
      expect(d10).to be > d4
    end
    it "sorts advantage dice lowest" do
      expect(d4).to be > advantage
      expect(d10).to be > advantage
      expect(advantage).to be < d4
      expect(advantage).to be < d10
    end
  end
end
