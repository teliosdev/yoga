# encoding: utf-8
# frozen_string_literal: true

require "fixtures/parser"
require "fixtures/scanner"

RSpec.describe Yoga::Parser do
  subject { Fixture::Parser.new(tokens) }
  let(:tokens) { Fixtures::Scanner.new(source) }
  let(:source) { "b = a + 2;\nb * 2;\n" }
end