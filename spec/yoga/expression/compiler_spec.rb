describe Expression::Compiler do
  subject { Expression.new(%q{"hello world"}) }

  context "#compile_paren" do
    it "raises an error on an invalid argument" do
      expect { subject.compile_paren(["hello"]) }.
        to raise_error(ArgumentError)
    end
  end
end
