module RelatonJis
  class BibliographicItem < RelatonIsoBib::IsoBibliographicItem
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
