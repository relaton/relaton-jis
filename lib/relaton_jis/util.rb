module RelatonJis
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonJis.configuration.logger
    end
  end
end
