# encoding: UTF-8

describe RelatonJis::DataFetcher do
  subject { described_class.new "data", "bibxml" }
  let(:next_url) { "https://webdesk.jsa.or.jp/books/W11M0070/getAddList" }
  let(:next_body) { { all_search_flg: "all_search", offset: 100, search_type: "KOKUNAI" } }
  let(:bib) do
    docid = RelatonBib::DocumentIdentifier.new(id: "JIS A 1301:1994", type: "JIS", primary: true)
    RelatonJis::BibliographicItem.new docid: [docid]
  end

  context "initialize" do
    it { expect(subject.instance_variable_get(:@output)).to eq "data" }
    it { expect(subject.instance_variable_get(:@format)).to eq "bibxml" }
    it { expect(subject.instance_variable_get(:@ext)).to eq "xml" }
    it { expect(subject.instance_variable_get(:@files)).to be_instance_of Set }
    it { expect(subject.instance_variable_get(:@queue)).to be_instance_of SizedQueue }
    it { expect(subject.instance_variable_get(:@mutex)).to be_instance_of Mutex }
    it { expect(subject.instance_variable_get(:@threads)).to be_instance_of Array }
  end

  context ".fetch" do
    before { expect(subject).to receive(:fetch) }

    it "with default values" do
      expect(FileUtils).to receive(:mkdir_p).with("data")
      expect(described_class).to receive(:new).with("data", "yaml").and_return subject
      described_class.fetch
    end

    it "with custom values" do
      expect(FileUtils).to receive(:mkdir_p).with("dir")
      expect(described_class).to receive(:new).with("dir", "xml").and_return subject
      described_class.fetch output: "dir", format: "xml"
    end
  end

  context "instance methods" do
    context "#fetch" do
      let(:url1) { "https://webdesk.jsa.or.jp/books/W11M0270/index" }
      let(:url2) { "https://webdesk.jsa.or.jp/books/W11M0070/index" }
      let(:body) { { all_search_flg: "all_search", search_type: "KOKUNAI" } }
      let(:resp) do
        Nokogiri::HTML(<<~HTML)
          <body>
            <form id="search_by_keyword" name="search_by_keyword" method="post" action="https://webdesk.jsa.or.jp/books/W11M0080/index">
              <input type="hidden" name="offset" id="offset" value="50">
            </form>
          </body>
        HTML
      end

      it "no results" do
        expect(subject.agent).to receive(:post).with(url1, body).and_return double(body: { "status" => false }.to_json)
        expect(subject.agent).not_to receive(:get)
        subject.fetch
      end

      it "with results" do
        expect(subject.agent).to receive(:post).with(url1, body).and_return double(body: { "status" => true }.to_json)
        expect(subject.agent).to receive(:get).with(url2).and_return resp
        expect(subject).to receive(:parse_page).with(resp)
        expect(subject.index).to receive(:save)
        subject.fetch
      end
    end

    context "#parse_page" do
      let(:page1) { Nokogiri::HTML(File.read("spec/fixtures/page1.html", encoding: "UTF-8")) }
      let(:page2) { Nokogiri::HTML(File.read("spec/fixtures/page2.html", encoding: "UTF-8")) }
      let(:queue) { subject.instance_variable_get :@queue }
      before do
        expect(subject).to receive(:fetch_doc).with(/\/index\/\?bunsyo_id=\w+/).exactly(50).times
      end

      it "first page" do
        expect(subject).to receive(:get_next_page).with(50)
        subject.parse_page page1
      end

      it "next page" do
        subject.instance_variable_set :@count, 110
        expect(subject).to receive(:get_next_page).with(100)
        subject.parse_page page2
      end

      it "no more pages" do
        expect(subject).not_to receive(:get_next_page)
        subject.parse_page page2
      end
    end

    context "#get_next_page" do
      it "success" do
        expect(subject).to receive(:initial_post).and_return true
        expect(subject.agent).to receive(:post).with(next_url, next_body).and_return :next_page
        expect(subject.get_next_page(100)).to eq :next_page
      end

      it "initial failed" do
        expect(subject).to receive(:initial_post).and_return false
        expect(subject.agent).not_to receive(:post)
        expect(subject.get_next_page(100)).to be_nil
      end

      it "post failed" do
        allow(subject).to receive(:sleep)
        expect(subject).to receive(:initial_post).and_return(true).exactly(5).times
        expect(subject.agent).to receive(:post).with(next_url, next_body).and_raise(StandardError).exactly(5).times
        expect do
          expect(subject.get_next_page(100)).to be_nil
        end.to output(/WARN: StandardError/).to_stderr_from_any_process
      end
    end

    context "#fetch_doc" do
      let(:scraper) { double "scraper" }
      before { allow(RelatonJis::Scraper).to receive(:new).with("url").and_return scraper }

      it "success" do
        expect(scraper).to receive(:fetch).and_return :bib
        expect(subject).to receive(:save_doc).with(:bib, "url")
        subject.fetch_doc "url"
      end

      it "failed" do
        expect(subject).to receive(:sleep).exactly(4).times
        expect(scraper).to receive(:fetch).and_raise(StandardError).exactly(5).times
        expect(subject).not_to receive(:save_doc)
        expect { subject.fetch_doc "url" }.to output(/WARN: StandardError/).to_stderr_from_any_process
      end
    end

    context "#save_doc" do
      let(:id) { "JIS A 1301:1994" }
      let(:file) { "data/JIS_A_1301_1994.xml" }

      it "file exists" do
        subject.instance_variable_get(:@files) << file
        expect { subject.save_doc bib, "url" }.to output(
          /File #{file} already exists. Duplication URL: url/,
        ).to_stderr_from_any_process
      end

      it "file does not exist" do
        expect(File).to receive(:write).with(file, /JIS\.A\.1301:1994/, encoding: "UTF-8")
        expect(subject.index).to receive(:add_or_update).with(id, file)
        subject.save_doc bib, "url"
      end
    end

    context "#serialize" do
      it "yaml" do
        subject.instance_variable_set :@format, "yaml"
        expect(bib.to_hash.to_yaml).to eq subject.serialize(bib)
      end

      it "xml" do
        subject.instance_variable_set :@format, "xml"
        expect(bib.to_xml(bibdata: true)).to eq subject.serialize(bib)
      end

      it "bibxml" do
        expect(bib.to_bibxml).to eq subject.serialize(bib)
      end
    end
  end
end
