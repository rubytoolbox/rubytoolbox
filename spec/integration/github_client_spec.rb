# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubClient, :real_http do
  let(:client) { described_class.new }

  describe "#fetch_repository" do
    describe "for existing repo", vcr: { cassette_name: "graphql/rails" } do
      let(:expected_attributes) do
        {
          archived?:                   false,
          average_recent_committed_at: a_value > Time.utc(2018, 3, 1),
          closed_issues_count:         a_value > 10_000,
          closed_pull_requests_count:  a_value > 6000,
          code_of_conduct_name:        "Other",
          code_of_conduct_url:         "https://github.com/rails/rails/blob/master/CODE_OF_CONDUCT.md",
          created_at:                  Time.zone.parse("2008-04-11T02:19:47Z"),
          default_branch:              "master",
          description:                 "Ruby on Rails",
          fork?:                       false,
          forks_count:                 a_value > 10_000,
          homepage_url:                "https://rubyonrails.org",
          issues?:                     true,
          license:                     "mit",
          merged_pull_requests_count:  a_value > 13_000,
          mirror?:                     false,
          open_issues_count:           a_value > 10,
          open_pull_requests_count:    a_value > 50,
          total_pull_requests_count:   a_value > 100,
          path:                        "rails/rails",
          primary_language:            "Ruby",
          pushed_at:                   a_value >= Time.zone.parse("2018-03-12T19:56:09Z"),
          stargazers_count:            a_value > 35_000,
          topics:                      %w[rails mvc html activerecord activejob ruby framework].sort,
          watchers_count:              a_value > 2500,
          wiki?:                       false,
        }
      end

      it "can fetch a whole bunch of data about the repository in question" do
        expect(client.fetch_repository("rails/rails")).to have_attributes(expected_attributes)
      end
    end

    describe "for invalid reference to an org", vcr: { cassette_name: "github/org_reference" } do
      it "raises a GithubClient::UnknownRepoError" do
        expect { client.fetch_repository("orgs/acdcorp") }.to raise_error(
          GithubClient::UnknownRepoError, /NOT_FOUND/
        )
      end
    end

    describe "for unknown repo", vcr: { cassette_name: "graphql/fails" } do
      it "raises a GithubClient::UnknownRepoError" do
        expect { client.fetch_repository("thisverylikely/fails") }.to raise_error(
          GithubClient::UnknownRepoError, /NOT_FOUND/
        )
      end
    end

    describe "for empty repo", vcr: { cassette_name: "graphql/empty" } do
      it "successfully fetches the repo" do
        expected_attributes = {
          pushed_at: nil,
        }
        expect(client.fetch_repository("therabidbanana/eventbright")).to have_attributes(expected_attributes)
      end
    end

    # This is currently not possible with Github's GraphQL API :(
    # https://platform.github.community/t/repository-redirects-in-api-v4-graphql/4417
    #
    describe "for a moved repo", vcr: { cassette_name: "jnicklas/carrierwave" } do
      it "resolves to the real repository path" do
        response = client.fetch_repository "jnicklas/carrierwave"
        expect(response.path).to be == "carrierwaveuploader/carrierwave"
      end
    end
  end

  describe "#fetch_readme" do
    shared_examples_for "a readme response" do |path|
      it "returns html content and etag wrapped in a ReadmeData object" do
        expect(client.fetch_readme(path))
          .to be_a(described_class::ReadmeData)
          .and have_attributes(
            html: kind_of(String),
            etag: /"[a-f0-9]+"/
          )
      end
    end

    describe "for existing repo", vcr: { cassette_name: "github/readme/existing" } do
      it_behaves_like "a readme response", "rspec/rspec"

      it "raises CacheHit on etag cache hit" do
        etag = client.fetch_readme("rspec/rspec").etag

        expect { client.fetch_readme("rspec/rspec", etag: etag) }.to raise_error(described_class::CacheHit)
      end
    end

    describe "for permanently moved repo", vcr: { cassette_name: "github/readme/moved" } do
      it_behaves_like "a readme response", "colszowka/simplecov"
    end

    describe "for unknown repo", vcr: { cassette_name: "github/readme/unknown" } do
      it "gracefully returns nil" do
        expect(client.fetch_readme("colszowka/nope")).to be nil
      end
    end
  end
end
