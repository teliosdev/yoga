describe Expression::Parser do
  let :klass do
    Class.new do
      include Expression::Parser

      def compile_contain(contain)
        [:CONTAIN, contain.map(&:last).join('')]
      end

      def compile_modifier(mod, v)
        [mod, v]
      end

      def compile_string(string)
        string
      end
    end
  end

  subject { klass.new }

  context "#parse" do
    let(:input) {
      [
        [:LBRACK],
        [:CHARACTER, "h"],
        [:CHARACTER, "e"],
        [:CHARACTER, "l"],
        [:CHARACTER, "l"],
        [:CHARACTER, "o"],
        [:RBRACK],
        [:STAR],
        [:OPTIONAL],
        [:STRING, "world"]
      ]
    }

    it "properly parses" do
      expect(subject.parse(input)).to eq [
        [:OPTIONAL, [:STAR, [:CONTAIN, "hello"]]],
        [:STRING, "world"]
      ]
    end
  end
end
