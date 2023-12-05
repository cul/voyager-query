# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'update resource', type: :request do
  let(:identifier) { 1401112 }

  context 'GET' do
    context '/api/v1/records/:id/record.marc' do
      let(:identifier_get_url) { "/api/v1/records/#{identifier}/record.marc" }
      let(:title) { 'test title' }
      let(:marc_record) do
        record = MARC::Record.new
        # record.append(MARC::ControlField.new('001', identifier.to_s))
        record.append(MARC::DataField.new('245', '0', '0', ['a', title]))
        record
      end

      before do
        allow_any_instance_of(Voyager::Client).to receive(:find_by_bib_id).with(identifier).and_return(marc_record)
      end

      it 'returns a success response' do
        get_with_auth identifier_get_url, params: {}
        expect(response).to have_http_status(:success)
      end

      it 'returns a response contiaining the identifier when using the record identifier in the url' do
        get_with_auth identifier_get_url, params: {}
        record = MARC::Reader.new(StringIO.new(response.body)).first
        expect(record.fields('245')[0]['a']).to eq(title)
      end
    end
  end
end
