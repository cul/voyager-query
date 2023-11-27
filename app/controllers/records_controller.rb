# frozen_string_literal: true

class RecordsController < ApplicationController
  def info_json
    holdings = Voyager::Client.new(VOYAGER_CONFIG).retrieve_holdings(params[:bib_id])
    render json: { bib_id: params[:bib_id].to_i, holdings_record_ids: holdings.keys }
    # render json: { bib_id: "#{params[:bib_id]}", holdings_record_ids: "#{holdings.keys.map(&:to_s)}" }
  end

  def bib_record_marc
    marc = Voyager::Client.new(VOYAGER_CONFIG).find_by_bib_id(params[:bib_id])
    send_data marc.to_marc, {filename: 'record.marc'}
  end

  def holdings_record_marc
    holdings = Voyager::Client.new(VOYAGER_CONFIG).retrieve_holdings(params[:bib_id])

    send_data holdings[Integer(params[:holdings_record_id])]
  end
end
