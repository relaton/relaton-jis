describe RelatonJis::HashConverter do
  it "returns a RelatonJis::BibliographicItem" do
    bib = described_class.bib_item title: [{ content: "title" }]
    expect(bib).to be_instance_of(RelatonJis::BibliographicItem)
  end
end
