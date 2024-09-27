module RelatonJis
  class Hit < RelatonBib::Hit
    #
    # Create new hit
    #
    # @param [Nokogiri::XML::Element] node found node
    # @param [RelatonJis::HitCollection] collection hit collection
    #
    # @return [RelatonJis::Hit] new hit
    #
    def self.create(hit, collection)
      # a = node.at("./a")
      # hit = { id: a.at("./text()").text.strip, url: a["href"] }
      new hit, collection
    end

    #
    # Check if hit matches reference
    #
    # @param [Hash] ref_parts parts of reference
    # @param [String, nil] year year
    # @param [Boolean] all_parts check all parts of reference
    #
    # @return [Boolean] true if hit matches reference
    #
    def eq?(ref_parts, year = nil, all_parts: false) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
      id_parts[:code].include?(ref_parts[:code]) &&
        (all_parts || (ref_parts[:part].nil? || ref_parts[:part] == id_parts[:part])) &&
        (year.nil? || year == id_parts[:year]) &&
        ((ref_parts[:expl].nil? || !id_parts[:expl].nil?) &&
         (ref_parts[:expl_num].nil? || ref_parts[:expl_num] == id_parts[:expl_num])) &&
        ((ref_parts[:amd].nil? || !id_parts[:amd].nil?) &&
          (ref_parts[:amd_num].nil? || ref_parts[:amd_num] == id_parts[:amd_num]) &&
          (ref_parts[:amd_year].nil? || ref_parts[:amd_year] == id_parts[:amd_year]))
    end

    #
    # Return parts of document id
    #
    # @return [Hash] hash with parts of document id
    #
    def id_parts
      @id_parts ||= hit_collection.parse_ref hit[:id]
    end

    def fetch
      return @fetch if defined? @fetch

      # @fetch = Scraper.new(hit[:url]).fetch
      yaml = Mechanize.new.get("#{Bibliography::GH_URL}#{hit[:file]}").body
      hash = YAML.safe_load yaml
      @fetch = RelatonJis::BibliographicItem.from_hash hash
      @fetch.fetched = Date.today.to_s
      @fetch
    end
  end
end
