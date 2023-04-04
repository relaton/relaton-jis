module RelatonJis
  class HitCollection < RelatonBib::HitCollection
    #
    # Initialize hit collection
    #
    # @param [String] text reference
    # @param [String, nil] year year
    # @param [Nokogiri::XML::NodeSet] result <description>
    #
    def initialize(text, year = nil, result:)
      super text, year
      @array = result.map { |h| Hit.create h, self }
    end

    #
    # Find hit in collection
    #
    # @return [RelatonJis::BibliographicItem, Array<Strig>] hash with bib ot array of missed years
    #
    def find
      missed_years = []
      y = year || ref_parts[:year]
      @array.each do |hit|
        return hit.fetch if hit.match? ref_parts, y

        missed_years << hit.id_parts[:year] if y && hit.match?(ref_parts)
      end
      missed_years
    end

    def find_all_parts
      hits = @array.select { |hit| hit.match? ref_parts, year, all_parts: true }
      item = hits.min_by { |i| i.id_parts[:part].to_i }.fetch.to_all_parts
      hits.each do |hit|
        next if hit.hit[:id] == item.docidentifier.first.id

        docid = RelatonBib::DocumentIdentifier.new id: hit.hit[:id], type: "JIS", primary: true
        fref = RelatonBib::FormattedRef.new content: hit.hit[:id]
        bibitem = BibliographicItem.new docid: [docid], formattedref: fref
        item.relation << RelatonBib::DocumentRelation.new(type: "instance", bibitem: bibitem)
      end
      item
    end

    #
    # Return parts of reference
    #
    # @return [Hash] hash with parts of reference
    #
    def ref_parts
      @ref_parts ||= parse_ref text
    end

    #
    # Parse reference
    #
    # @param [String] ref reference
    #
    # @return [Hash] hash with parts of reference
    #
    def parse_ref(ref)
      %r{
        ^(?<code>\w+\s\w\s?\w+)
        (?:-(?<part>\w+))?
        (?::(?<year>\d{4}))?
        (?:/(?<expl>EXPL(?:ANATION)?)(?:\s(?<expl_num>\d+))?)?
        (?:/(?<amd>AMDENDMENT)(?:\s(?<amd_num>\d+)(?::(?<amd_year>\d{4}))?)?)?
      }x =~ ref
      { code: code, part: part, year: year, expl: expl, expl_num: expl_num,
        amd: amd, amd_num: amd_num, amd_year: amd_year }
    end
  end
end
