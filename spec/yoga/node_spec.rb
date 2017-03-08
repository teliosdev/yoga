# encoding: utf-8
# frozen_string_literal: true

require "fixtures/parser"

RSpec.describe Yoga::Node do
  subject { Fixtures::Parser::Literal.new(value: value, location: location) }
  let(:value) { "2" }
  let(:location) { Yoga::Location.default }

  context "#update" do
    let(:updated)  { subject.update(update_data) }
    let(:update_data) { { value: 2 } }
    it "updates a given attribute" do
      expect(updated.value).to eq 2
    end

    context "with an invalid attribute" do
      let(:update_data) { { foo: :bar } }

      it "fails" do
        expect { updated }.to raise_error(::ArgumentError)
      end
    end
  end

  context "#prevent_update" do
    let(:updated) { subject.prevent_update }

    it "doesn't allow an update" do
      expect { updated.update(value: 2) }.to raise_error(::NoMethodError)
    end

    it "allows updates on the original" do
      expect { subject.update(value: 2) }.not_to raise_error(::StandardError)
    end
  end
end
