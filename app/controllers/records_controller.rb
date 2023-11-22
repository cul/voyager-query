# frozen_string_literal: true

class RecordsController < ApplicationController
  def info_json
    holdings = Voyager::Client.new(VOYAGER_CONFIG).retrieve_holdings(params[:bib_id])
    render json: { bib_id: "#{params[:bib_id]}", holdings_record_ids: "#{holdings[params[:bib_id]]}" }
  end

  def bib_record_marc
    marc = Voyager::Client.new(VOYAGER_CONFIG).find_by_bib_id(params[:bib_id])
    send_file marc
    render json: { page: 'bib_record'}
  end

  def holdings_record_marc
    holdings = Voyager::Client.new(VOYAGER_CONFIG).retrieve_holdings(params[:bib_id])
    render json: holdings
  end
end
