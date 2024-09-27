module RelatonJis
  module HashConverter
    include RelatonIsoBib::HashConverter
    extend self

    # @param item_hash [Hash]
    # @return [Relaton3gpp::BibliographicItem]
    def bib_item(item_hash)
      BibliographicItem.new(**item_hash)
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end
