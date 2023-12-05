# frozen_string_literal: true

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
    end
  end
end
