# frozen_string_literal: true

module V1
  class RecordsController < ApiController
    before_action :authenticate_request_token#, only: [:bib_record_marc]

    def info_json
      holdings = Voyager::Client.new(VOYAGER_CONFIG).retrieve_holdings(params[:bib_id].to_i)
      render json: { bib_id: params[:bib_id].to_i, holdings_record_ids: holdings.keys }
    end

    def bib_record_marc
      marc = Voyager::Client.new(VOYAGER_CONFIG).find_by_bib_id(params[:bib_id].to_i)
      send_data marc.to_marc, { filename: 'record.marc' }
    end

    def holdings_record_marc
      holdings = Voyager::Client.new(VOYAGER_CONFIG).retrieve_holdings(params[:bib_id].to_i)
      send_data holdings[Integer(params[:holdings_record_id])]
    end
  end
end
