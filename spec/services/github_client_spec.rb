# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubClient do
  let(:token) { "Hello World" }
  let(:client) { described_class.new token: token }

  it "raises an InvalidResponseStatus when the response has status 400" do
    stub_request(:post, "https://api.github.com/graphql")
      .to_return(status: 400)

    expect { client.fetch_repository("rspec/rspec") }.to raise_error(
      described_class::InvalidResponseStatus, /status=400/
    )
  end

  it "raises an InvalidResponse when there are errors in the graphql response" do
    response_body = JSON.dump(errors: [{ message: "hello world" }])

    stub_request(:post, "https://api.github.com/graphql")
      .to_return(status: 200, body: response_body)

    expect { client.fetch_repository("foo/bar") }.to raise_error(
      described_class::InvalidResponse, /hello world/
    )
  end
end
