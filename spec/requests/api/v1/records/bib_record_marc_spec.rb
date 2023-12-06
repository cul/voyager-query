# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'update resource', type: :request do
  let(:identifier) { 1401112 }

  context 'GET' do
    context '/api/v1/records/:id' do
      let(:identifier_get_url) { "/api/v1/records/#{identifier}" }

      context 'without proper authorization' do
        it 'returns an unauthorized response' do
          get identifier_get_url, params: {}
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with proper authorization' do
        before do
          allow_any_instance_of(Voyager::Client).to receive(:retrieve_holdings).with(identifier).and_return(
            { identifier.to_i => 'binary marc data' }
          )
        end

        it 'returns a success response' do
          get_with_auth identifier_get_url, params: {}
          expect(response).to have_http_status(:success)
        end

        it 'returns a response contiaining the identifier when using the record identifier in the url' do
          get_with_auth identifier_get_url, params: {}
          expect(JSON.parse(response.body)).to include('bib_id' => identifier)
        end
      end
    end
  end
end
