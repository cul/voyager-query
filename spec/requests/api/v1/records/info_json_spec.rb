# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'update resource', type: :request do
  let(:identifier) { 1401112 }

  context 'GET' do
    context '/api/v1/records/:bib_id/holdings/:holdings_record_id/record.marc' do
      let(:holdings_identifier) { 1742778 }
      let(:identifier_get_url) { "/api/v1/records/#{identifier}/holdings/#{holdings_identifier}/record.marc" }

      context 'without proper authorization' do
        it 'returns an unauthorized response' do
          get identifier_get_url, params: {}
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with proper authorization' do
        before do
          allow_any_instance_of(Voyager::Client).to receive(:retrieve_holdings).with(identifier).and_return(
            { holdings_identifier.to_i => '00046     2200037   45000010008000001742778' }
          )
        end

        it 'returns a success response' do
          get_with_auth identifier_get_url, params: {}
          expect(response).to have_http_status(:success)
        end

        it 'returns a response contiaining the identifier when using the record identifier in the url' do
          get_with_auth identifier_get_url, params: {}
          record = MARC::Reader.new(StringIO.new(response.body)).first
          expect(record.fields('001')[0].to_s[4..]).to eq(holdings_identifier.to_s)
        end
      end
    end
  end
end
