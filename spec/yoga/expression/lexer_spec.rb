describe Expression::Lexer do
  let :klass do
    Class.new do
      include Expression::Lexer

      def initialize(body)
        @body = body
      end
    end
  end


  subject do
    klass.new(body)
  end

  context "#scan" do
    let(:body) { "[hello] | 'world'" }
    it "properly scans" do
      expect(scan).to eq [
        [:LBRACK],
        [:CHARACTER, "h"],
        [:CHARACTER, "e"],
        [:CHARACTER, "l"],
        [:CHARACTER, "l"],
        [:CHARACTER, "o"],
        [:RBRACK],
        [:UNION],
        [:STRING, "world"]
      ]
    end

    context "with a complicated input" do
      let(:body) { %q{(("hello" & 42) | ([a]* world{1,2} -- "a" - "b"))+?} }

      it "still scans" do
        expect(scan).to eq [
          [:LPAREN],
          [:LPAREN],
          [:STRING, "hello"],
          [:INTERSECT],
          [:NUMBER, "42"],
          [:RPAREN],
          [:UNION],
          [:LPAREN],
          [:LBRACK],
          [:CHARACTER, "a"],
          [:RBRACK],
          [:STAR],
          [:CHARACTER, "w"],
          [:CHARACTER, "o"],
          [:CHARACTER, "r"],
          [:CHARACTER, "l"],
          [:CHARACTER, "d"],
          [:REPETITION, "1", true, "2"],
          [:SDIFFERENCE],
          [:STRING, "a"],
          [:DIFFERENCE],
          [:STRING, "b"],
          [:RPAREN],
          [:RPAREN],
          [:PLUS],
          [:OPTIONAL]
        ]
      end
    end
  end

  context "#string_escapes" do
    let(:body) { nil }
    it "properly handles escapes" do
      expect(subject.string_escapes("\\n\\a\\x42")).to eq "\n\a\x42"
    end
  end

  def scan
    Timeout.timeout(1) do
      subject.scan
    end
  end
end
