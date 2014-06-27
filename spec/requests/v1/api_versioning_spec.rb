require 'spec_helper'

describe "api versioning with accept headers", type: :request do

  it "does not allow incorrect api version headers" do
    expect { get "/api/users" }.to raise_error(ActionController::RoutingError)
  end

  it "allows correct api version headers" do
    get "/api/users", nil, { "HTTP_ACCEPT" => "application/vnd.api+json; version=1" }
    expect(response.status).to eq(401)
  end
end
