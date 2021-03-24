require "spec_helper"

RSpec.describe WickedResult do
  describe ".initialize" do
    context "when given a set of dice" do
      let(:randomizer1) { class_double(Random) }
      let(:randomizer2) { class_double(Random) }

      before do
        allow(randomizer1).to receive(:rand).and_return(3)
        allow(randomizer2).to receive(:rand).and_return(5)
      end

      let(:dice) do
        [WickedDie.create(die: "d8", randomizer: randomizer1),
         WickedDie.create(die: "d8", randomizer: randomizer2)]
      end

      let(:subject) { described_class.new(dice) }

      it "saves the dice" do
        expect(subject.dice).to match_array(dice)
      end

      it "rolls the dice and saves the result" do
        expect(subject.values).to contain_exactly(3, 5)
      end
    end
  end

  describe ".result" do
    context "when given a regular set of dice" do
      let(:randomizer1) { class_double(Random) }
      let(:randomizer2) { class_double(Random) }

      before do
        allow(randomizer1).to receive(:rand).and_return(3)
        allow(randomizer2).to receive(:rand).and_return(10)
      end

      let(:dice) do
        [WickedDie.create(die: "d8", randomizer: randomizer1),
         WickedDie.create(die: "d12", randomizer: randomizer2)]
      end

      let(:subject) { described_class.new(dice) }

      it "shows the results in a nice format" do
        expect(subject.result).to eq("10, 3 (d12: 10, d8: 3)")
      end
    end

    context "when given dice with an advantage die" do
      let(:randomizer1) { class_double(Random) }
      let(:randomizer2) { class_double(Random) }
      let(:randomizerA) { class_double(Random) }

      before do
        allow(randomizer1).to receive(:rand).and_return(3)
        allow(randomizer2).to receive(:rand).and_return(10)
        allow(randomizerA).to receive(:rand).and_return(5)
      end

      let(:dice) do
        [WickedDie.create(die: "d8", randomizer: randomizer1),
         WickedDie.create(die: "d12", randomizer: randomizer2),
         WickedDie.create(die: "A", randomizer: randomizerA)]
      end

      let(:subject) { described_class.new(dice) }

      it "includes the advantage die in the highest value" do
        expect(subject.result).to eq("15, 3 (d12: 10, d8: 3, advantage: 5)")
      end
    end
  end

  describe "#advantage_dice" do
    let(:dice) do
      [WickedDie.create(die: "d8"),
       WickedDie.create(die: "d12")]
    end

    let(:subject) { described_class.new(dice) }

    it "returns no dice when given a set of dice with no advantage die" do
      expect(subject.advantage_dice).to be_empty
    end

    it "returns the advantage die when given a set of dice with an advantage die" do
      advantage_die = WickedDie.create(die: "A")
      dice << advantage_die
      expect(subject.advantage_dice).to eq([advantage_die])
    end

    it "returns all advantage dice when there are multiple advantage dice" do
      advantage_dice = [WickedDie.create(die: "A"), WickedDie.create(die: "A")]
      dice.push(*advantage_dice)
      expect(subject.advantage_dice).to match_array(advantage_dice)
    end
  end

  describe "#standard_dice" do
    let(:standard_dice) do
      [WickedDie.create(die: "d8"),
        WickedDie.create(die: "d12")]
    end

    let(:dice) { standard_dice.clone }

    let(:subject) { described_class.new(dice) }

    it "returns just the standard dice when given a set of dice with no advantage die" do
      expect(subject.standard_dice).to match_array(standard_dice)
    end

    it "returns just the standard dice when given a set of dice with an advantage die" do
      advantage_die = WickedDie.create(die: "A")
      dice << advantage_die
      expect(subject.standard_dice).to match_array(standard_dice)
    end

    it "returns jsut the standard dice when there are multiple advantage dice" do
      advantage_dice = [WickedDie.create(die: "A"), WickedDie.create(die: "A")]
      dice.push(*advantage_dice)
      expect(subject.standard_dice).to match_array(standard_dice)
    end
  end

  describe "#unmodified_values" do
    let(:randomizer1) { class_double(Random) }
    let(:randomizer2) { class_double(Random) }
    let(:randomizerA1) { class_double(Random) }
    let(:randomizerA2) { class_double(Random) }

    before do
      allow(randomizer1).to receive(:rand).and_return(8)
      allow(randomizer2).to receive(:rand).and_return(4)
      allow(randomizerA1).to receive(:rand).and_return(2)
      allow(randomizerA2).to receive(:rand).and_return(1)
    end

    let(:dice) do
      [WickedDie.create(die: "d8", randomizer: randomizer1),
       WickedDie.create(die: "d12", randomizer: randomizer2)]
    end

    let(:subject) { described_class.new(dice) }

    it "returns just the standard dice values when there are no advantage dice" do
      expect(subject.unmodified_values).to eq([8, 4])
    end

    it "returns just the standard dice values when there is one advantage die" do
      advantage_die = WickedDie.create(die: "A")
      dice << advantage_die
      expect(subject.unmodified_values).to eq([8, 4])
    end

    it "returns just the standard dice values when there are multiple advantage dice" do
      advantage_dice = [WickedDie.create(die: "A"), WickedDie.create(die: "A")]
      dice.push(*advantage_dice)
      expect(subject.unmodified_values).to eq([8, 4])
    end
  end

  describe "#advantage_sum" do
    let(:randomizer1) { class_double(Random) }
    let(:randomizer2) { class_double(Random) }
    let(:randomizerA1) { class_double(Random) }
    let(:randomizerA2) { class_double(Random) }

    before do
      allow(randomizer1).to receive(:rand).and_return(8)
      allow(randomizer2).to receive(:rand).and_return(4)
      allow(randomizerA1).to receive(:rand).and_return(2)
      allow(randomizerA2).to receive(:rand).and_return(1)
    end

    let(:dice) do
      [WickedDie.create(die: "d8", randomizer: randomizer1),
       WickedDie.create(die: "d12", randomizer: randomizer2)]
    end

    let(:subject) { described_class.new(dice) }

    it "returns 0 when there are no advantage dice" do
      expect(subject.advantage_sum).to eq(0)
    end

    it "returns the value of the advantage die when there is just one" do
      advantage_die = WickedDie.create(die: "A", randomizer: randomizerA1)
      dice << advantage_die
      expect(subject.advantage_sum).to eq(2)
    end

    it "returns the sum of the advantage dice when there multiple dice" do
      advantage_dice = [WickedDie.create(die: "A", randomizer: randomizerA1), WickedDie.create(die: "A", randomizer: randomizerA2)]
      dice.push(*advantage_dice)
      expect(subject.advantage_sum).to eq(3)
    end
  end

  describe "#values" do
    let(:randomizer1) { class_double(Random) }
    let(:randomizer2) { class_double(Random) }
    let(:randomizerA1) { class_double(Random) }
    let(:randomizerA2) { class_double(Random) }

    before do
      allow(randomizer1).to receive(:rand).and_return(8)
      allow(randomizer2).to receive(:rand).and_return(4)
      allow(randomizerA1).to receive(:rand).and_return(2)
      allow(randomizerA2).to receive(:rand).and_return(1)
    end

    let(:dice) do
      [WickedDie.create(die: "d8", randomizer: randomizer1),
       WickedDie.create(die: "d12", randomizer: randomizer2)]
    end

    let(:subject) { described_class.new(dice) }

    it "returns the standard dice values when there are no advantage dice" do
      expect(subject.values).to eq([8, 4])
    end

    it "returns the first value increased by the advantage total" do
      advantage_dice = [WickedDie.create(die: "A", randomizer: randomizerA1), WickedDie.create(die: "A", randomizer: randomizerA2)]
      dice.push(*advantage_dice)
      expect(subject.values).to eq([11, 4])
    end
  end
end
