describe RelatonJis::DocumentType do
  it "warn if type is not valid" do
    expect do
      RelatonJis::DocumentType.new type: "invalid"
    end.to output(/\[relaton-jis\] WARN: invalid doctype: `invalid`/).to_stderr_from_any_process
  end
end
