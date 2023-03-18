module RelatonJis
  class HashConverter < RelatonBib::HashConverter
    # @param item_hash [Hash]
    # @return [Relaton3gpp::BibliographicItem]
    def self.bib_item(item_hash)
      BibliographicItem.new(**item_hash)
    end
  end
end
