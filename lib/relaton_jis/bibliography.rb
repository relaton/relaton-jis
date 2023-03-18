module RelatonJis
  module Bibliography
    extend self

    SOURCE = "https://webdesk.jsa.or.jp/books/W11M".freeze

    #
    # Search JIS by keyword
    #
    # @param [String] code JIS documetnt code
    # @param [String, nil] year JIS document year
    #
    # @return [RelatonJis::HitCollection] search result
    #
    def search(code, year = nil)
      agent = Mechanize.new
      resp = agent.post "#{SOURCE}0010/searchByKeyword", search_type: "JIS", keyword: code
      disp = JSON.parse resp.body
      result = agent.get "#{SOURCE}#{disp['disp_screen']}/index"
      HitCollection.new code, year, result: result.xpath("//div[@class='blockGenaral']")
    end

    #
    # Get JIS document by reference
    #
    # @param [String] ref JIS document reference
    # @param [String] year JIS document year
    # @param [Hash] _opts options
    #
    # @return [RelatonJis::BibliographicItem, nil] JIS document
    #
    def get(ref, year = nil, _opts = {})
      warn "[relaton-jis] (\"#{ref}\") fetching..."
      result = search(ref, year).find
      if result[:bib]
        warn "[relaton-jis] (\"#{ref}\") found #{result[:bib].docidentifier[0].id}"
        return result[:bib]
      end
      hint result, ref, year
    end

    #
    # Log hint message
    #
    # @param [Hash] result search result
    # @param [String] ref reference to search
    # @param [String, nil] year year to search
    #
    def hint(result, ref, year)
      warn "[relaton-jis] (\"#{ref}\") not found. The identifier must be " \
           "exactly as shown on the webdesk.jsa.or.jp website."
      if result[:missed_years]
        warn "[relaton-jis] (\"#{ref}\") TIP: No match for edition year #{year}, " \
             "but matches exist for #{result[:missed_years].uniq.join(', ')}."
      end
    end
  end
end
