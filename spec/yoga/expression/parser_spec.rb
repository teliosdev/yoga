describe Expression::Parser do
  let :klass do
    Class.new do
      include Expression::Parser
    end
  end

  subject { klass.new }

  context "#parse" do
    let(:input) { [[:CONTAIN, "hello"], [:STAR], [:OPTIONAL], [:STRING, "world"]] }

    it "properly parses" do
      expect(subject.parse(input)).to eq [
        [:OPTIONAL, [:STAR, [:CONTAIN, "hello"]]],
        [:STRING, "world"]
      ]
    end
  end
end
