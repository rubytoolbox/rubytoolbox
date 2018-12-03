# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubClient, :real_http do
  let(:client) { described_class.new }

  describe "for existing repo", vcr: { cassette_name: "graphql/rails" } do
    let(:expected_attributes) do
      {
        archived?:                   false,
        average_recent_committed_at: a_value > Time.utc(2018, 3, 1),
        closed_issues_count:         a_value > 10_000,
        closed_pull_requests_count:  a_value > 6000,
        created_at:                  Time.zone.parse("2008-04-11T02:19:47Z"),
        default_branch:              "master",
        description:                 "Ruby on Rails",
        fork?:                       false,
        forks_count:                 a_value > 10_000,
        homepage_url:                "http://rubyonrails.org",
        issues?:                     true,
        license:                     "mit",
        merged_pull_requests_count:  a_value > 13_000,
        mirror?:                     false,
        open_issues_count:           a_value > 10,
        open_pull_requests_count:    a_value > 50,
        path:                        "rails/rails",
        primary_language:            "Ruby",
        pushed_at:                   a_value >= Time.zone.parse("2018-03-12T19:56:09Z"),
        stargazers_count:            a_value > 35_000,
        watchers_count:              a_value > 2500,
        wiki?:                       false,
      }
    end

    it "can fetch a whole bunch of data about the repository in question" do
      expect(client.fetch_repository("rails/rails")).to have_attributes(expected_attributes)
    end
  end

  describe "for unknown repo", vcr: { cassette_name: "graphql/fails" } do
    it "raises a GithubClient::UnknownRepoError" do
      expect { client.fetch_repository("thisverylikely/fails") }.to raise_error(
        GithubClient::UnknownRepoError, /Cannot find repo/
      )
    end
  end

  # This is currently not possible with Github's GraphQL API :(
  # https://platform.github.community/t/repository-redirects-in-api-v4-graphql/4417
  #
  describe "for a moved repo", vcr: { cassette_name: "graphql/carrierwave" } do
    it "resolves to the real repository path" do
      response = client.fetch_repository "jnicklas/carrierwave"
      expect(response.path).to be == "carrierwaveuploader/carrierwave"
    end
  end
end
