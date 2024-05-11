describe RelatonJis::XMLParser do
  it "returns a RelatonJis::BibliographicItem" do
    bib = described_class.send :bib_item, title: [{ content: "title" }]
    expect(bib).to be_instance_of(RelatonJis::BibliographicItem)
  end

  it "creates a RelatonJis::DocumentType" do
    xml = Nokogiri::XML("<doctype abbreviation='TR'>technicla-report</doctype>").at "doctype"
    doctype = described_class.send :create_doctype, xml
    expect(doctype).to be_instance_of RelatonJis::DocumentType
    expect(doctype.type).to eq "technicla-report"
    expect(doctype.abbreviation).to eq "TR"
  end
end
