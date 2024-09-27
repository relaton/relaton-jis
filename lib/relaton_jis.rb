# frozen_string_literal: true

require "mechanize"
require "relaton_iso_bib"
require "relaton/index"
require_relative "relaton_jis/version"
require_relative "relaton_jis/util"
require_relative "relaton_jis/document_type"
require_relative "relaton_jis/bibliographic_item"
require_relative "relaton_jis/xml_parser"
require_relative "relaton_jis/hash_converter"
require_relative "relaton_jis/scraper"
require_relative "relaton_jis/bibliography"
require_relative "relaton_jis/hit_collection"
require_relative "relaton_jis/hit"
require_relative "relaton_jis/data_fetcher"

module RelatonJis
  class Error < StandardError; end

  # Returns hash of XML reammar
  # @return [String]
  def self.grammar_hash
    # gem_path = File.expand_path "..", __dir__
    # grammars_path = File.join gem_path, "grammars", "*"
    # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
    Digest::MD5.hexdigest RelatonJis::VERSION + RelatonIsoBib::VERSION + RelatonBib::VERSION # grammars
  end
end
