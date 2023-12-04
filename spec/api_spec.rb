require 'rails_helper'

RSpec.describe 'update resource', type: :request do
  let(:identifier) { 1401112 }

  context 'GET' do
    context '/v1/records/:id' do
      let(:identifier_get_url) { "/v1/records/#{identifier}" }

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

    context '/v1/records/:id/record.marc' do
      let(:identifier_get_url) { "/v1/records/#{identifier}/record.marc" }
      let(:title) { "test title" }
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

    context '/v1/records/:bib_id/holdings/:holdings_record_id/record.marc' do
      let(:holdings_identifier) { 1742778 }
      let(:identifier_get_url) { "/v1/records/#{identifier}/holdings/#{holdings_identifier}/record.marc" }

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
