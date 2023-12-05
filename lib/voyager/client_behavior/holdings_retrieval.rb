# frozen_string_literal: true

module Voyager
  module ClientBehavior
    module HoldingsRetrieval
      extend ActiveSupport::Concern

      def retrieve_holdings(bib_id)
        results = execute_select_command_with_retry(fill_in_query_placeholders('select MFHD_ID from bib_mfhd where bib_id = ~bibid~', bibid: bib_id))

        holdings_keys = []
        results.each do |result|
          holdings_keys << result['MFHD_ID']
        end

        holdings_ids_to_records = {}

        holdings_keys.each do |holdings_key|
          holdings_ids_to_records[holdings_key] ||= ''
          results = execute_select_command_with_retry(fill_in_query_placeholders('select RECORD_SEGMENT from mfhd_data where mfhd_id = ~mfhd_id~ order by seqnum', mfhd_id: holdings_key))
          results.each do |result|
            holdings_ids_to_records[holdings_key] += result['RECORD_SEGMENT']
          end
        end

        holdings_ids_to_records
      end
    end
  end
end
