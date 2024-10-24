# encoding: UTF-8

module RelatonJis
  class Scraper
    ATTRS = %i[
      title link abstract docid docnumber date type language script
      docstatus doctype ics contributor editorialgroup structuredidentifier
    ].freeze

    LANGS = { "和文" => { lang: "ja", script: "Jpan" },
              "英訳" => { lang: "en", script: "Latn" } }.freeze

    DATETYPES = { "発行年月日" => "issued", "確認年月日" => "confirmed" }.freeze
    STATUSES = { "有効" => "valid", "廃止" => "withdrawn" }.freeze

    def initialize(url)
      @url = url
      @agent = Mechanize.new
    end

    def fetch
      @doc = @agent.get(@url).at "//div[@id='main']/section"
      attrs = ATTRS.each_with_object({}) do |attr, hash|
        hash[attr] = send "fetch_#{attr}"
      end
      BibliographicItem.new(**attrs)
    end

    # def fetch_fetched
    #   Date.today.to_s
    # end

    def fetch_title
      { "ja" => "Jpan", "en" => "Lant" }.map.with_index do |(lang, script), i|
        content = @doc.at("./h2/text()[#{i + 2}]").text.strip
        RelatonBib::TypedTitleString.new content: content, language: lang, script: script
      end
    end

    def fetch_link
      src = RelatonBib::TypedUri.new content: @url, type: "src"
      uri = URI @url
      domain = "#{uri.scheme}://#{uri.host}"
      @doc.xpath("./dl/dt[.='プレビュー']/following-sibling::dd[1]/a").reduce([src]) do |mem, node|
        href = "#{domain}#{node[:href]}"
        mem << RelatonBib::TypedUri.new(content: href, type: "pdf")
      end
    end

    def fetch_abstract
      @doc.xpath("//div[@id='honbun']").map do |node|
        RelatonBib::FormattedString.new content: node.text.strip, language: "ja", script: "Jpan"
      end
    end

    def fetch_docid
      [RelatonBib::DocumentIdentifier.new(id: document_id, type: "JIS", primary: true)]
    end

    def fetch_docnumber
      match = document_id.match(/^\w+\s(\w)\s?(\d+)/)
      "#{match[1]}#{match[2]}"
    end

    def document_id
      @document_id ||= @doc.at("./h2/text()[1]").text.strip
    end

    def fetch_date
      DATETYPES.each_with_object([]) do |(key, type), a|
        node = @doc.at("./div/div/div/p/text()[contains(.,'#{key}')]")
        next unless node

        on = node.text.match(/\d{4}-\d{2}-\d{2}/).to_s
        a << RelatonBib::BibliographicDate.new(type: type, on: on)
      end
    end

    def fetch_type
      "standard"
    end

    def fetch_language
      langs_scripts.map { |l| l[:lang] }
    end

    def fetch_script
      langs_scripts.map { |l| l[:script] }
    end

    def langs_scripts
      @langs_scripts ||= LANGS.each_with_object([]) do |(key, lang), a|
        l = @doc.at("./div/div/div[@class='blockContentFile']/div/div/p[1]/span[contains(.,'#{key}')]/following-sibling::span")
        next if l.nil? || l.text.strip == "-"

        a << lang
      end
    end

    def fetch_docstatus
      st = @doc.at("./div/div/div/p/text()[contains(.,'状態')]/following-sibling::span")
      return unless st

      RelatonBib::DocumentStatus.new(stage: STATUSES[st.text.strip])
    end

    def fetch_doctype
      type =  case document_id
              when /JIS\s[A-Z]\s[\w-]+:\d{4}\/AMENDMENT/ then "amendment"
              when /JIS\s[A-Z]\s[\w-]+/ then "japanese-industrial-standard"
              when /TR[\s\/][\w-]+/ then "technical-report"
              when /TS[\s\/][\w-]+/ then "technical-specification"
              end
      DocumentType.new type: type
    end

    def fetch_ics
      td = @doc.at("./table/tr[th[.='ICS']]/td")
      return [] unless td

      td.text.strip.split.map { |code| RelatonIsoBib::Ics.new code }
    end

    def fetch_contributor
      authorizer = create_contrib("一般財団法人　日本規格協会", "authorizer")
      @doc.xpath("./table/tr[th[.='原案作成団体']]/td").reduce([authorizer]) do |a, node|
        a << create_contrib(node.text.strip, "author")
        a << create_contrib(node.text.strip, "publisher")
      end
    end

    def create_contrib(name, role)
      org = RelatonBib::Organization.new name: create_orgname(name)
      RelatonBib::ContributionInfo.new entity: org, role: [type: role]
    end

    def create_orgname(name)
      orgname = [RelatonBib::LocalizedString.new(name, "ja", "Jpan")]
      if name.include?("日本規格協会")
        orgname << RelatonBib::LocalizedString.new("Japanese Industrial Standards", "en", "Latn")
      end
      orgname
    end

    def fetch_editorialgroup
      node = @doc.at("./table/tr[th[.='原案作成団体']]/td")
      return unless node

      tc = RelatonBib::WorkGroup.new name: node.text.strip
      RelatonIsoBib::EditorialGroup.new technical_committee: [tc]
    end

    def fetch_structuredidentifier
      RelatonIsoBib::StructuredIdentifier.new project_number: fetch_docnumber, type: "JIS"
    end
  end
end
