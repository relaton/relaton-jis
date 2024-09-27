module RelatonJis
  module Bibliography
    extend self

    # SOURCE = "https://webdesk.jsa.or.jp/books/W11M".freeze
    GH_URL = "https://raw.githubusercontent.com/relaton/relaton-data-jis/refs/heads/main/".freeze

    #
    # Search JIS by keyword
    #
    # @param [String] code JIS documetnt code
    # @param [String, nil] year JIS document year
    #
    # @return [RelatonJis::HitCollection] search result
    #
    def search(code, year = nil)
      index = Relaton::Index.find_or_create(:jis, url: "#{GH_URL}index-v1.zip", file: DataFetcher::INDEX_FILE)
      result = index.search(code).sort_by { |h| h[:id] }
      HitCollection.new code, year, result: result # .xpath("//div[@class='blockGenaral']")
    end

    #
    # Get JIS document by reference
    #
    # @param [String] ref JIS document reference
    # @param [String] year JIS document year
    # @param [Hash] opts options
    # @option opts [String] :all_parts return all parts of document
    #
    # @return [RelatonJis::BibliographicItem, nil] JIS document
    #
    def get(ref, year = nil, opts = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      code = ref.sub(/\s\((all parts|規格群)\)/, "")
      opts[:all_parts] ||= !$1.nil?
      Util.info "Fetching from webdesk.jsa.or.jp ...", key: ref
      hits = search(code, year)
      unless hits
        hint [], ref, year
        return
      end
      result = opts[:all_parts] ? hits.find_all_parts : hits.find
      if result.is_a? RelatonJis::BibliographicItem
        Util.info "Found: `#{result.docidentifier[0].id}`", key: ref
        return result
      end
      hint result, ref, year
    end

    #
    # Log hint message
    #
    # @param [Array] result search result
    # @param [String] ref reference to search
    # @param [String, nil] year year to search
    #
    def hint(result, ref, year)
      Util.info "Not found.", key: ref
      if result.any?
        Util.info "TIP: No match for edition year `#{year}`, but " \
                  "matches exist for `#{result.uniq.join('`, `')}`.", key: ref
      end
      nil
    end
  end
end
