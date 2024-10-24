describe RelatonJis::Scraper do
  context "instance methods" do
    subject { RelatonJis::Scraper.new "https://document.url" }

    context "#fetch" do
      let(:doc) { Nokogiri::HTML File.read "spec/fixtures/jis_x_0208_1997.html", encoding: "UTF-8" }

      before do
        agent = subject.instance_variable_get :@agent
        expect(agent).to receive(:get).with("https://document.url").and_return doc
      end

      it do
        item = subject.fetch
        expect(item).to be_instance_of RelatonJis::BibliographicItem
        expect(item.title.size).to eq 2
        expect(item.title.first).to be_instance_of RelatonBib::TypedTitleString
        expect(item.link.size).to eq 2
        expect(item.link.first).to be_instance_of RelatonBib::TypedUri
        expect(item.abstract.first).to be_instance_of RelatonBib::FormattedString
        expect(item.docidentifier.first).to be_instance_of RelatonBib::DocumentIdentifier
        expect(item.date.size).to eq 2
        expect(item.date.first).to be_instance_of RelatonBib::BibliographicDate
        expect(item.type).to eq "standard"
        expect(item.language.first).to eq "ja"
        expect(item.script.first).to eq "Jpan"
        expect(item.status).to be_instance_of RelatonBib::DocumentStatus
        expect(item.doctype).to be_instance_of RelatonJis::DocumentType
        expect(item.ics.first).to be_instance_of RelatonIsoBib::Ics
        expect(item.contributor.size).to eq 3
        expect(item.contributor.first).to be_instance_of RelatonBib::ContributionInfo
        expect(item.editorialgroup).to be_instance_of RelatonIsoBib::EditorialGroup
        expect(item.structuredidentifier).to be_instance_of RelatonIsoBib::StructuredIdentifier
      end
    end

    context "#fetch_doctype" do
      shared_examples "doctype" do |id, doctype|
        it do
          expect(subject).to receive(:document_id).and_return id
          expect(subject.fetch_doctype.type).to eq doctype
        end
      end

      it_behaves_like "doctype", "JIS A 1301:1994/AMENDMENT 1:2011", "amendment"
    end

    it "#fetch_ics" do
      doc = Nokogiri::HTML(<<~HTML).at("//div[@id='main']/section")
        <div id="main">
          <section>
            <table>
              <tr>
                <th>ICS</th>
                <td class="content">
                                                                                                                        01.040.01<br>
                                                                                    01.120<br>
                                                                                                            </td>
              </tr>
            </table>
          </section>
        </div>
      HTML
      subject.instance_variable_set :@doc, doc
      ics = subject.fetch_ics
      expect(ics).to be_instance_of Array
      expect(ics.size).to eq 2
      expect(ics.first).to be_instance_of RelatonIsoBib::Ics
      expect(ics.first.code).to eq "01.040.01"
      expect(ics.last.code).to eq "01.120"
    end
  end
end
