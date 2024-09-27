require "relaton/processor"

module RelatonJis
  class Processor < Relaton::Processor
    attr_reader :idtype

    def initialize # rubocop:disable Lint/MissingSuper
      @short = :relaton_jis
      @prefix = "JIS"
      @defaultprefix = %r{^(JIS|TR)\s}
      @idtype = "JIS"
      @datasets = %w[jis-webdesk]
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonJis::BibliographicItem]
    def get(code, date, opts)
      ::RelatonJis::Bibliography.get(code, date, opts)
    end

    #
    # Fetch all the docukents from a source
    #
    # @param [String] _source source name
    # @param [Hash] opts
    # @option opts [String] :output directory to output documents
    # @option opts [String] :format
    #
    def fetch_data(_source, opts)
      DataFetcher.fetch(**opts)
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

    #
    # Remove index file
    #
    def remove_index_file
      Relaton::Index.find_or_create(:jis, url: true, file: DataFetcher::INDEX_FILE).remove_file
    end
  end
end
