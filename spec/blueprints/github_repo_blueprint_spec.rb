# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubRepoBlueprint, type: :blueprint do
  fixtures :all

  let(:repo) do
    GithubRepo.new path: "foo/bar"
  end

  let(:json) do
    described_class.render_as_hash repo
  end

  %i[
    path
    description
    url
    wiki_url
    primary_language
    is_fork
    is_mirror
    license
    repo_pushed_at
    average_recent_committed_at
  ].each do |attribute|
    it "serializes #{attribute}" do
      allow(repo).to receive(attribute).and_return "fake value"
      expect(json[attribute]).to be == "fake value"
    end
  end

  it "serializes archived? as is_archived" do
    allow(repo).to receive(:archived?).and_return "fake value"
    expect(json[:is_archived]).to be == "fake value"
  end

  describe "stats" do
    %i[
      stargazers_count
      forks_count
      watchers_count
    ].each do |attribute|
      it "serializes #{attribute}" do
        allow(repo).to receive(attribute).and_return "fake value"
        expect(json[:stats][attribute]).to be == "fake value"
      end
    end
  end

  describe "pull_requests" do
    {
      url:             :pull_requests_url,
      open_count:      :open_pull_requests_count,
      closed_count:    :closed_pull_requests_count,
      merged_count:    :merged_pull_requests_count,
      total_count:     :total_pull_requests_count,
      acceptance_rate: :pull_request_acceptance_rate,
    }.each do |name, source|
      it "serializes #{source} as #{name}" do
        allow(repo).to receive(source).and_return "fake value"
        expect(json[:pull_requests][name]).to be == "fake value"
      end
    end
  end

  describe "issues" do
    {
      url:          :issues_url,
      open_count:   :open_issues_count,
      closed_count: :closed_issues_count,
      total_count:  :total_issues_count,
      closure_rate: :issue_closure_rate,
    }.each do |name, source|
      it "serializes #{source} as #{name}" do
        repo.has_issues = true
        allow(repo).to receive(source).and_return "fake value"
        expect(json[:issues][name]).to be == "fake value"
      end
    end

    it "is nil when repo has issues disabled" do
      expect(json[:issues]).to be_nil
    end
  end
end
