module Voyager
  module ClientBehavior
    module HoldingsRetrieval
      extend ActiveSupport::Concern

      ORACLE_WAIT_TIMEOUT = 10.seconds

      def holdings_for_bib_id(bib_id)
        # path = Rails.root.join('tmp', 'holdings', 'record.marc').to_s
        path = Rails.root.join('tmp', 'holdings').to_s

        FileUtils.mkdir_p(path)
        duration = Benchmark.realtime do
          retrieve_holdings(bib_id).each do |holding_id, holding_marc|
            path_to_file = File.join(path, "#{holding_id}.marc")
            File.binwrite(path_to_file, holding_marc)
          end
        end
        Rails.logger.debug("Downloaded holdings to #{path}. Took #{duration} seconds.")

        result_counter = 0
        Dir.foreach(path) do |entry|
          next unless entry.ends_with?('.marc')
          marc_file = File.join(path, entry)
          begin
            # Note 1: Need to process oracle-retrieved files with UTF-8 encoding
            # (the default encoding for the MARC::Reader) in order to get
            # correctly formatted utf-8 characters. This is different than what
            # we would do over Z39.50, where we want to use MARC-8 instead.
            # Note 2: Marc::Reader is sometimes bad about closing files, and this
            # causes problems with NFS locks on NFS volumes, so we'll
            # read in the file and pass the content in as a StringIO.
            holdings_marc_record = MARC::Reader.new(StringIO.new(File.read(marc_file))).first
            yield holdings_marc_record, result_counter, num_results
          rescue Encoding::InvalidByteSequenceError => e
            # Re-raise error, appending a bit of extra info
            raise e, "Problem decoding characters for holdings marc file #{marc_file}. Error message: #{$!}", $!.backtrace
            # To troubleshoot this error further, it can be useful to examine the record's text around the
            # byte range location given in the encoding error. Smart quotes are a common cause of problems.
          end
          result_counter += 1
        end
      end

      def retrieve_holdings(bib_id)
        results = execute_select_command_with_retry(fill_in_query_placeholders("select MFHD_ID from bib_mfhd where bib_id = ~bibid~", bibid: bib_id))

        holdings_keys = []
        results.each do |result|
          holdings_keys << result['MFHD_ID']
        end

        holdings_ids_to_records = {}

        holdings_keys.each do |holdings_key|
          holdings_ids_to_records[holdings_key] ||= ''
          results = execute_select_command_with_retry(fill_in_query_placeholders("select RECORD_SEGMENT from mfhd_data where mfhd_id = ~mfhd_id~ order by seqnum", mfhd_id: holdings_key))
          results.each do |result|
            holdings_ids_to_records[holdings_key] += result['RECORD_SEGMENT']
          end
        end

        holdings_ids_to_records
      end
    end
  end
end
