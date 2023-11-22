describe RelatonJis::Bibliography do
  before { RelatonJis.instance_variable_set :@configuration, nil }

  context "class methods" do
    context ".get" do
      it "returns empty array if not found" do
        expect(described_class).to receive(:search).and_return nil
        expect do
          expect(described_class.get("JIS X 0208")).to be_nil
        end.to output(/\[relaton-jis\] \(JIS X 0208\) Not found\./).to_stderr
      end
    end
  end

  it "searches JIS", vcr: { cassette_name: "search" } do
    result = described_class.search "JIS X 0208"
    expect(result).to be_instance_of(RelatonJis::HitCollection)
    expect(result.size).to eq(2)
    expect(result.first).to be_instance_of(RelatonJis::Hit)
    expect(result[0].hit[:id]).to eq("JIS X 0208:1997")
    expect(result[0].hit[:url]).to include "/index/?bunsyo_id="
  end

  context "get JIS" do
    it "without year", vcr: { cassette_name: "get" } do
      file = "spec/fixtures/jis_x_0208.xml"
      bib = described_class.get "JIS X 0208"
      xml = bib.to_xml bibdata: true
      File.write file, xml, encoding: "UTF-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
        .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      schema = Jing.new "grammars/relaton-jis-compile.rng"
      errors = schema.validate file
      expect(errors).to eq []
    end

    it "with year", vcr: { cassette_name: "get" } do
      expect do
        bib = described_class.get "JIS X 0208:1997"
        expect(bib.docidentifier.first.id).to eq "JIS X 0208:1997"
      end.to output(/\[relaton-jis\] \(JIS X 0208:1997\) Found: `JIS X 0208:1997`/).to_stderr
    end

    it "with year as argument", vcr: { cassette_name: "get" } do
      bib = described_class.get "JIS X 0208", "1997"
      expect(bib.docidentifier.first.id).to eq "JIS X 0208:1997"
    end

    it "with wrong year", vcr: { cassette_name: "get" } do
      expect do
        bib = described_class.get "JIS X 0208", "1998"
        expect(bib).to be_nil
      end.to output(/TIP: No match for edition year `1998`/).to_stderr
    end

    it "withdrawn", vcr: { cassette_name: "withdrawn" } do
      bib = described_class.get "JIS Z 8201"
      expect(bib.docidentifier.first.id).to eq "JIS Z 8201"
    end

    it "does not find", vcr: "not_found" do
      expect do
        bib = described_class.get "JIS Z 0000"
        expect(bib).to be_nil
      end.to output(/Not found/).to_stderr
    end

    context "with all parts", vcr: { cassette_name: "get_all_parts" } do
      it "EN" do
        file = "spec/fixtures/jis_b_0060_all_parts.xml"
        bib = described_class.get "JIS B 0060 (all parts)"
        xml = bib.to_xml bibdata: true
        File.write file, xml, encoding: "UTF-8" unless File.exist? file
        expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
          .gsub(/(?<=<fetched>)\d{4}-\d{2}-\d{2}/, Date.today.to_s)
      end

      it "JP" do
        bib = described_class.get "JIS B 0060 (規格群)"
        expect(bib.docidentifier.first.id).to eq "JIS B 0060 (all parts)"
      end

      it "option" do
        bib = described_class.get "JIS B 0060", nil, all_parts: true
        expect(bib.docidentifier.first.id).to eq "JIS B 0060 (all parts)"
      end
    end
  end
end
