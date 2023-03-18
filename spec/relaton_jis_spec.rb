# frozen_string_literal: true

RSpec.describe RelatonJis do
  it "has a version number" do
    expect(RelatonJis::VERSION).not_to be nil
  end

  it "returs grammar hash" do
    hash = RelatonJis.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end
end
