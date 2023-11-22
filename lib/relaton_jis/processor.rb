require "relaton/processor"

module RelatonJis
  class Processor < Relaton::Processor
    attr_reader :idtype

    def initialize # rubocop:disable Lint/MissingSuper
      @short = :relaton_jis
      @prefix = "JIS"
      @defaultprefix = %r{^(JIS|TR)\s}
      @idtype = "JIS"
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonJis::BibliographicItem]
    def get(code, date, opts)
      ::RelatonJis::Bibliography.get(code, date, opts)
    end

    # @param xml [String]
    # @return [RelatonJis::BibliographicItem]
    def from_xml(xml)
      ::RelatonJis::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonJis::BibliographicItem]
    def hash_to_bib(hash)
      item_hash = ::RelatonJis::HashConverter.hash_to_bib(hash)
      ::RelatonJis::BibliographicItem.new(**item_hash)
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonJis.grammar_hash
    end
  end
end
