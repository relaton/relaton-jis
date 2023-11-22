module RelatonJis
  class BibliographicItem < RelatonIsoBib::IsoBibliographicItem
    DOCTYPES = %w[japanese-industrial-standard technical-report technical-specification amendment].freeze
    #
    # Fetch the flavor shcema version
    #
    # @return [String] schema version
    #
    def ext_schema
      @ext_schema ||= schema_versions["relaton-model-jis"]
    end
  end
end
