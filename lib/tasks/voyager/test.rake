# frozen_string_literal: true

namespace :voyager do
  namespace :test do
    task check_oracle_connection: :environment do
      oracle_config = VOYAGER_CONFIG[:oracle]
      puts "Attempting to connect to Voyager at: #{oracle_config[:host]}:#{oracle_config[:port]} ..."
      oracle_connection = OCI8.new(
        oracle_config[:user],
        oracle_config[:password],
        "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=#{oracle_config[:host]})(PORT=#{oracle_config[:port]}))(CONNECT_DATA=(SID=#{oracle_config[:database_name]})))"
      )
      puts "Connection available? #{oracle_connection.ping}"
    rescue OCIError => e
      puts "Connection available? false (Error: #{e.message})"
    ensure
      oracle_connection&.break
    end

    task check_oci8_encoding: :environment do
      puts "OCI8 encoding is: #{OCI8.encoding.inspect}"
    end
  end
end
