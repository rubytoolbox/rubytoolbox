# frozen_string_literal: true

require "rails_helper"

RSpec.describe Database::SelectiveExport do
  fixtures :all

  describe described_class::Scopes do # rubocop:disable RSpec/EmptyExampleGroup
    def self.expect_scope(name)
      describe ".#{name}" do
        subject(:query) { described_class.public_send(name).to_sql }

        it { is_expected.to eq yield.to_sql }
      end
    end

    expect_scope(:category_groups) { CategoryGroup.all }
    expect_scope(:categories) { Category.all }
    expect_scope :projects do
      Project.where(permalink: Project.joins(:categories).distinct)
             .or(Project.where(permalink: Project.order(score: :desc).limit(1000)))
    end

    expect_scope(:categorizations) { Categorization.where project: described_class.projects }

    expect_scope(:rubygems) { Rubygem.where project: described_class.projects }
    expect_scope :rubygem_download_stats do
      Rubygem::DownloadStat.where(rubygem_name: described_class.rubygems.pluck(:name))
                           .where("date >= ?", 3.months.ago.to_date)
                           .order(date: :asc)
    end
    expect_scope :rubygem_code_statistics do
      Rubygem::CodeStatistic.where rubygem: described_class.rubygems
    end
    expect_scope :rubygem_dependencies do
      RubygemDependency.where rubygem: described_class.rubygems, dependency: described_class.rubygems
    end
    expect_scope :rubygem_trends do
      Rubygem::Trend.where(rubygem: described_class.rubygems).where("date >= ?", 1.month.ago.to_date)
    end

    expect_scope(:github_repos) { GithubRepo.where projects: described_class.projects }
    expect_scope :github_readmes do
      Github::Readme.where github_repo: described_class.github_repos.limit(300).order(stargazers_count: :desc)
    end
    expect_scope :github_ignores do
      GithubIgnore.all
    end
  end

  describe ".sql_inserts_from_scope(scope)" do
    let(:scope) { Project.order(permalink: :asc) }

    it "yields SQL insert statements" do
      insert_sql = nil
      described_class.sql_inserts_from_scope(scope) { insert_sql = _1 }
      original_count = scope.count

      scope.delete_all

      expect { ApplicationRecord.connection.execute insert_sql }
        .to change(scope, :count).from(0).to original_count
    end

    context "when scope is empty" do
      let(:scope) { Project.none }

      it { expect { described_class.sql_inserts_from_scope(scope, &_1) }.not_to yield_control }
    end
  end

  describe described_class::EXPORT_ORDER do
    let(:expected) do
      %i[
        category_groups
        categories
        rubygems
        rubygem_download_stats
        rubygem_code_statistics
        rubygem_dependencies
        rubygem_trends
        github_repos
        github_readmes
        github_ignores
        projects
        categorizations
      ]
    end

    it { is_expected.to eq expected }
  end

  describe ".call" do
    subject(:export_contents) do
      (+"").tap do |export|
        described_class.call do |file|
          Zlib::GzipReader.open(file) { export << _1.read }
        end
      end
    end

    let(:expected_contents) do
      (+"").tap do |output|
        described_class::EXPORT_ORDER.each do |table_name|
          described_class.sql_inserts_from_scope described_class::Scopes.public_send(table_name) do |sql|
            output << sql
          end
        end
      end
    end

    it { is_expected.to eq expected_contents }

    it "removes the file after completion" do
      path = nil
      described_class.call { path = _1.path }
      expect(File.exist?(path)).to be false
    end
  end
end
