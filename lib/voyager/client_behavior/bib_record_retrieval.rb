module Voyager
  module ClientBehavior
    module BibRecordRetrieval
      extend ActiveSupport::Concern

      # Finds a single record by bib id
      # @return [MARC::Record] The MARC record associated with the given id.
      def find_by_bib_id(bib_id)
        path = Rails.root.join('tmp', 'bib', 'record.marc').to_s

        FileUtils.mkdir_p(File.dirname(path))
        duration = Benchmark.realtime do
          File.binwrite(path, retrieve_bib_marc(bib_id))
        end
        Rails.logger.debug("Downloaded bib to #{path}. Took #{duration} seconds.")

        begin
          # Note 1: Need to process oracle-retrieved files with UTF-8 encoding
          # (the default encoding for the MARC::Reader) in order to get
          # correctly formatted utf-8 characters. This is different than what
          # we would do over Z39.50, where we want to use MARC-8 instead.
          # Note 2: Marc::Reader is sometimes bad about closing files, and this
          # causes problems with NFS locks on NFS volumes, so we'll
          # read in the file and pass the content in as a StringIO.
          bib_marc_record = MARC::Reader.new(StringIO.new(File.read(path))).first
          return bib_marc_record
        rescue Encoding::InvalidByteSequenceError => e
          # Re-raise error, appending a bit of extra info
          raise e, "Problem decoding characters for record in marc file #{bib_id}. Error message: #{$!}", $!.backtrace
          # To troubleshoot this error further, it can be useful to examine the record's text around the
          # byte range location given in the encoding error. Smart quotes are a common cause of problems.
        end
        nil
      end

      def retrieve_bib_marc(bib_id)
        results = execute_select_command_with_retry(fill_in_query_placeholders("select RECORD_SEGMENT from bib_data where bib_id = ~bibid~ order by seqnum", bibid: bib_id))
        bib_marc = ''
        results.each do |result|
          bib_marc += result['RECORD_SEGMENT']
        end
        bib_marc
      end

      def retrieve_multiple_bib_marc_records(bib_ids)
        prepared_statement_keys_to_values = bib_ids.map.with_index { |bib_id, i| ["id#{i}", bib_id] }.to_h
        query = "select RECORD_SEGMENT, BIB_ID from bib_data where BIB_ID IN (~#{prepared_statement_keys_to_values.keys.join("~,~")}~) order by seqnum"
        results = execute_select_command_with_retry(fill_in_query_placeholders(query, prepared_statement_keys_to_values))

        bib_marc_records = bib_ids.map { |bib_id| [bib_id, ''] }.to_h
        results.each do |result|
          bib_marc_records[result['BIB_ID'].to_s] += result['RECORD_SEGMENT']
        end
        bib_marc_records
      end
    end
  end
end
