# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get '/records/:bib_id', to: 'records#info_json'
      get '/records/:bib_id/record.marc', to: 'records#bib_record_marc'
      get '/records/:bib_id/holdings/:holdings_record_id/record.marc', to: 'records#holdings_record_marc'
    end
  end
end
