module RelatonJis
  module XMLParser
    include RelatonBib::Parser::XML
    extend self
    # @param item_hash [Hash]
    # @return [RelatonSgpp::BibliographicItem]
    def bib_item(item_hash)
      BibliographicItem.new(**item_hash)
    end

    def create_doctype(type)
      DocumentType.new type: type.text, abbreviation: type[:abbreviation]
    end
  end
end
