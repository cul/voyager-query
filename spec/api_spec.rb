require 'rails_helper'

RSpec.describe "update resource", type: :request do
let(:identifier) { 1401112 }
  describe "GET /records/:id", focus: true do
    let(:identifier_get_url) { "/records/#{identifier}" }

    context "with authentication" do
        it "returns a success response when using the primary identifier in the url" do
            get_with_auth identifier_get_url, params: {}
            puts response
            expect(response).to have_http_status(:success)
        end
    end
  end
end