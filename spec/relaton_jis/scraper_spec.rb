describe RelatonJis::Scraper do
  context "instance methods" do
    subject { RelatonJis::Scraper.new "https://document.url" }

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
