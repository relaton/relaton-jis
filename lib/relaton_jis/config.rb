module RelatonJis
  module Config
    include RelatonBib::Config
  end
  extend Config

  class Configuration < RelatonBib::Configuration
    PROGNAME = "relaton-jis".freeze
  end
end
