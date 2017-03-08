# encoding: utf-8
# frozen_string_literal: true

RSpec.describe Yoga::Token do
  subject { described_class.new(:EOF, "", Yoga::Location.default) }

  context "#==" do
    let(:equiv) { described_class.new(:EOF, "", Yoga::Location.default) }
    let(:different) { described_class.new(:EOS, "", Yoga::Location.default) }

    it "equals itself" do
      expect(subject).to eq subject
    end

    it "equals an equivalent token" do
      expect(subject).to eq equiv
    end

    it "doesn't equal a different token" do
      expect(subject).to_not eq different
    end
  end

  context ".eof" do
    subject { described_class.eof }
    let(:eof) { described_class.new(:EOF, "", Yoga::Location.default) }

    it "is a token" do
      expect(subject).to eq eof
    end
  end
end
