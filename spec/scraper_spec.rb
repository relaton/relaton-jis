describe RelatonJis::Scraper do
  context "instance methods" do
    subject { RelatonJis::Scraper.new "https://document.url" }

    context "#fetch_doctype" do
      shared_examples "doctype" do |id, doctype|
        it do
          expect(subject).to receive(:document_id).and_return id
          expect(subject.fetch_doctype).to eq doctype
        end
      end

      it_behaves_like "doctype", "JIS A 1301:1994/AMENDMENT 1:2011", "amendment"
    end
  end
end
