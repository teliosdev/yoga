describe Machine do

  let(:first_part) do
    Machine::Part.new
  end

  let(:second_part) do
    part = Machine::Part.new
    part.transitions.create(on: ['a'].to_set, to: first_part)
    part.starting = true
    part
  end

  subject { Machine.new }

  before :each do
    subject.parts << first_part
    subject.parts << second_part
  end

  its(:alphabet) { should eq Set.new(["a"]) }

  context "#clone" do
    it "clones parts" do
      cloned = subject.clone
      expect(cloned.parts).to_not be subject.parts
      expect(cloned.parts.first).to eq subject.parts.first
      expect(cloned.parts.first).to_not be subject.parts.first
      expect(cloned.parts.last.transitions.first.to).to be cloned.parts.first
    end
  end

  context ".stringify_alphabet" do
    let(:alphabet) do
      ["a".."d", "m".."r", ["z", "d", "m"]].map(&:to_a).flatten.shuffle
    end

    it "properly formats the alphabet" do
      expect(subject.stringify_alphabet(alphabet)).to eq "'a'..'d', 'm'..'r', 'z'"
    end
  end
end
