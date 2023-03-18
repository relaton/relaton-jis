module RelatonJis
  class XMLParser < RelatonBib::XMLParser
    # @param item_hash [Hash]
    # @return [RelatonSgpp::BibliographicItem]
    def self.bib_item(item_hash)
      BibliographicItem.new(**item_hash)
    end
  end
end
