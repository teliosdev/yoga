# encoding: utf-8
# frozen_string_literal: true

require "fixtures/scanner"

RSpec.describe Yoga::Scanner do
  subject { Fixtures::Scanner.call(source) }
  let(:source) { "b = a + 2" }
  let(:tokens) do
    [t(:IDENT, "b", 1..2),
      t(:"=", "=", 3..4),
      t(:IDENT, "a", 5..6),
      t(:"+", "+", 7..8),
      t(:NUMERIC, "2", 9..10),
      t(:EOF, "", 10)]
  end

  context "#call" do
    it "returns an enumerable" do
      expect(subject).to be_a(Enumerable)
    end

    it "parses correctly" do
      expect(subject.to_a).to eq tokens
    end

    context "with lines" do
      let(:source) { "b = a + 2;\nb * 2;\n" }

      it "includes lines" do
        expect(subject.to_a[-3].location.line).to eq 2..2
      end
    end
  end

  def t(kind, value, col, line = 1..1)
    Yoga::Token.new(kind, value, Yoga::Location.new("<anon>", line, col))
  end
end
