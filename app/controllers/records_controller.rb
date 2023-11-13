# frozen_string_literal: true

class RecordsController < ApplicationController
  def info_json
    render json: { a: 'asdf', b: 'asgasfd' }
  end

  def bib_record_marc
    render json: { page: 'bib_record'}
  end

  def holdings_record_marc
    render json: { page: 'holdings_record'}
  end
end
