describe RelatonJis::HashConverter do
  it "returns a RelatonJis::BibliographicItem" do
    bib = described_class.bib_item title: [{ content: "title" }]
    expect(bib).to be_instance_of(RelatonJis::BibliographicItem)
  end

  it "create_doctype" do
    doctype = described_class.create_doctype type: "type"
    expect(doctype).to be_instance_of RelatonJis::DocumentType
    expect(doctype.type).to eq "type"
  end
end
