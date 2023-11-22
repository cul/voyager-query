module Voyager
  class Client
    include Voyager::ClientBehavior::OracleQueryBehavior
    include Voyager::ClientBehavior::HoldingsRetrieval
    include Voyager::ClientBehavior::BibRecordRetrieval

    REQUIRED_ORACLE_CONFIG_OPTS = [:host, :port, :database_name, :user, :password].freeze
    ORACLE_RETRIEVAL_BATCH_SIZE = 100

    def initialize(config)
      @oracle_config = config[:oracle]
      # Make sure oracle config options are present so there aren't any surprises later when queries are run
      REQUIRED_ORACLE_CONFIG_OPTS.each do |required_config_opt|
        raise ArgumentError, "Missing oracle config[:#{required_config_opt}] for #{self.class}" unless @oracle_config[required_config_opt].present?
      end
    end

    def oracle_connection
      @oracle_connection ||= OCI8.new(
        @oracle_config[:user],
        @oracle_config[:password],
        "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=#{@oracle_config[:host]})(PORT=#{@oracle_config[:port]}))(CONNECT_DATA=(SID=#{@oracle_config[:database_name]})))"
      ).tap do |connection|
        # When a select statement is executed, the OCI library allocates
        # a prefetch buffer to reduce the number of network round trips by
        # retrieving specified number of rows in one round trip.
        connection.prefetch_rows = 1000
      end
    end

    def break_oracle_connection!
      @oracle_connection.break
      # Attempt a clean disconnect from Oracle and then set the connection
      # variable to nil so that the oracle_connection method
      # re-establishes the connection when it is called again.
      @oracle_connection = nil
    end

  end
end
