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
        [:CONTAIN, "hello"],
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
          [:CONTAIN, "a"],
          [:STAR],
          [:IDENTIFIER, "world"],
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

  def scan
    Timeout.timeout(1) do
      subject.scan
    end
  end
end
