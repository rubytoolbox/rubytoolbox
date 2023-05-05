# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project do
  fixtures :all

  describe "associations" do
    subject(:model) { described_class.new }

    it {
      expect(model).to have_many(:categorizations)
        .with_primary_key(:permalink)
        .with_foreign_key(:project_permalink)
        .validate(false)
        .dependent(:destroy)
        .inverse_of(:project)
    }

    it { is_expected.to have_many(:categories).through(:categorizations) }

    it {
      expect(model).to belong_to(:rubygem)
        .with_primary_key(:name)
        .with_foreign_key(:rubygem_name)
        .inverse_of(:project)
        .optional
    }

    it {
      expect(model).to have_many(:reverse_dependencies)
        .through(:rubygem)
        .source(:reverse_dependency_projects)
        .order(score: :desc)
    }

    it {
      expect(model).to belong_to(:github_repo)
        .with_primary_key(:path)
        .with_foreign_key(:github_repo_path)
        .inverse_of(:projects)
        .optional
    }
  end

  it "does not allow mismatches between permalink and rubygem name" do
    project = described_class.create! permalink: "somegem"
    expect { project.update! rubygem_name: "othergem" }.to raise_error(
      ActiveRecord::StatementInvalid,
      /check_project_permalink_and_rubygem_name_parity/
    )
  end

  describe ".includes_associations" do
    before do
      rand(3..14).times { |i| Factories.project "project #{i}" }
    end

    it "only makes expected amount of queries" do
      nested_accessor = ->(p) { [p.categories.map(&:name), p.rubygem_downloads, p.github_repo_stargazers_count] }

      # Sometimes activerecord sprinkles in a `SELECT a.attname, format_type(a.atttypid, a.atttypmod),`
      # here for good measure. Actually it's supposed to be 4 queries.
      expect { described_class.includes_associations.map(&nested_accessor) }
        .to make_database_queries(count: 4..6)
    end
  end

  describe ".find_for_show!" do
    let(:project) do
      Factories.project "sample"
    end

    it "eager-loads readme if present" do
      project.github_repo.create_readme! html: "hello world", etag: "1234"

      found_instance = described_class.find_for_show!(project.permalink)
      expect { found_instance.github_repo_readme }.not_to make_database_queries
    end
  end

  describe ".with_bugfix_forks" do
    before do
      Factories.project "regular"
      Factories.project("forked").tap { |p| p.update! is_bugfix_fork: true }
    end

    it "omits bugfix_forks when given false" do
      expect(described_class.with_bugfix_forks(false).pluck(:permalink)).not_to include("forked")
    end

    it "includes bugfix_forks when given true" do
      scope = described_class.with_bugfix_forks(true).order(permalink: :asc)
      expect(scope.pluck(:permalink)).to include("forked", "regular")
    end
  end

  describe ".suggest" do
    it "does not make any database query for empty param" do
      expect { described_class.suggest(" ") }.not_to make_database_queries
    end

    it "returns empty array for empty param" do
      expect(described_class.suggest(" ")).to be == []
    end

    it "fetches projects from database that match given name ordered by score" do
      Factories.project "demofoo"
      Factories.project "foobar", score: 10
      Factories.project "foo", score: 5
      Factories.project "foofoo", score: nil
      expect(described_class.suggest("fo")).to be == %w[foobar foo foofoo]
    end

    it "is case-insensitive" do
      Factories.project "DeMo"
      expect(described_class.suggest("dem")).to be == %w[DeMo]
    end

    it "sanitizes user-provided special chars" do
      Factories.project "foof"
      expect(described_class.suggest("%oof")).to be == %w[]
    end
  end

  describe ".search" do
    it "can find a matching project" do
      expected = described_class.create! permalink: "widgets", score: 1
      described_class.create! permalink: "airplanes", score: 1
      described_class.create! permalink: "rockets", score: 1

      expect(described_class.search("widget")).to be == [expected]
    end

    it "does not return projects without a score" do
      expected = described_class.create! permalink: "somethingelse", score: 1, description: "Provides amazing widgets"
      described_class.create! permalink: "widgets"
      expect(described_class.search("widget")).to be == [expected]
    end

    describe "for projects flagged as bugfix forks" do
      let(:expected) do
        described_class.create! permalink: "somethingelse", score: 10, description: "Provides amazing widgets"
      end

      before do
        described_class.create! permalink: "widgets", is_bugfix_fork: true, score: 1
      end

      it "does not include them by default" do
        expect(described_class.search("widget")).to be == [expected]
      end

      it "includes them when called with show_forks true" do
        expect(described_class.search("widget", show_forks: true)).to be == [expected, described_class.find("widgets")]
      end
    end

    describe "result order" do
      before do
        (1..3).each do |i|
          rubygem = Rubygem.create! name: "widgets#{i}", downloads: 10 - i, current_version: "1.0"
          described_class.create! permalink: rubygem.name, score: 10 + i, rubygem:
        end
      end

      it "sorts results by the search result rank by default" do
        described_class.find("widgets2").update! description: "widgets widgets!"
        expected = %w[widgets2 widgets3 widgets1]
        expect(described_class.search("widget").pluck(:permalink)).to be == expected
      end

      it "allows to pass a custom order instance" do
        order = Project::Order.new(order: "rubygem_downloads")
        expected = %w[widgets1 widgets2 widgets3]
        expect(described_class.search("widget", order:).pluck(:permalink)).to be == expected
      end
    end
  end

  describe "#github_only?" do
    it "is false when no / is present in permalink" do
      expect(described_class.new(permalink: "foobar")).not_to be_github_only
    end

    it "is true when a / is present in permalink" do
      expect(described_class.new(permalink: "foo/bar")).to be_github_only
    end
  end

  describe "#github_repo_path=" do
    it "normalizes the path to the stripped, downcase variant" do
      expect(described_class.new(github_repo_path: " FoO/BaR ").github_repo_path).to be == "foo/bar"
    end
  end

  describe "url delegation" do
    %i[changelog_url documentation_url mailing_list_url].each do |url|
      describe "##{url}" do
        it "is fetched from the rubygem" do
          project = described_class.new(rubygem: Rubygem.new(url => "foobar"))
          expect(project.send(url)).to be == "foobar"
        end
      end
    end

    describe "#source_code_url" do
      let(:project) do
        described_class.new(
          rubygem:     Rubygem.new(source_code_url: "from_gem"),
          github_repo: GithubRepo.new(path: "foo/bar")
        )
      end

      it "prefers the gem's source code url" do
        expect(project.source_code_url).to be == project.rubygem_source_code_url
      end

      it "falls back to github repo url if not given in gem" do
        project.rubygem.source_code_url = nil
        expect(project.source_code_url).to be == project.github_repo_url
      end
    end

    describe "#homepage_url" do
      let(:project) do
        described_class.new(
          rubygem:     Rubygem.new(homepage_url: "from_gem"),
          github_repo: GithubRepo.new(homepage_url: "from_repo")
        )
      end

      it "prefers the gem's homepage url" do
        expect(project.homepage_url).to be == project.rubygem_homepage_url
      end

      it "falls back to github repo homepage url if not given in gem" do
        project.rubygem.homepage_url = nil
        expect(project.homepage_url).to be == project.github_repo_homepage_url
      end
    end

    describe "#wiki_url" do
      let(:project) do
        described_class.new(
          rubygem:     Rubygem.new(wiki_url: "from_gem"),
          github_repo: GithubRepo.new(path: "foo/bar")
        )
      end

      it "prefers the gem's wiki url" do
        expect(project.wiki_url).to be == project.rubygem_wiki_url
      end

      it "falls back to github repo wiki url if not given in gem" do
        project.rubygem.wiki_url = nil
        expect(project.wiki_url).to be == project.github_repo_wiki_url
      end
    end

    describe "#bug_tracker_url" do
      let(:project) do
        described_class.new(
          rubygem:     Rubygem.new(bug_tracker_url: "from_gem"),
          github_repo: GithubRepo.new(path: "foo/bar")
        )
      end

      it "prefers the gem's bug_tracker_url url" do
        expect(project.bug_tracker_url).to be == project.rubygem_bug_tracker_url
      end

      it "falls back to github repo issues url if not given in gem" do
        project.rubygem.bug_tracker_url = nil
        expect(project.bug_tracker_url).to be == project.github_repo_issues_url
      end
    end
  end

  describe "#name" do
    subject(:project) { described_class.new(permalink: SecureRandom.hex(10)) }

    it { is_expected.to have_attributes(name: project.permalink) }
  end

  describe "permalink=" do
    it "normalizes the permalink to the stripped, downcase variant for github repo" do
      expect(described_class.new(permalink: " FoO/BaR ").permalink).to be == "foo/bar"
    end

    it "does not normalize the permalink for non-github project" do
      expect(described_class.new(permalink: "FoOBaR").permalink).to be == "FoOBaR"
    end
  end

  describe "#health" do
    let(:project) { described_class.new }

    it "passes itself to Project Health" do
      expect(Project::Health).to receive(:new).with(project)
      project.health
    end

    it "returns a project health instance" do
      health = instance_double Project::Health
      allow(Project::Health).to receive(:new).and_return(health)
      expect(project.health).to be == health
    end

    # rubocop:disable RSpec/IdenticalEqualityAssertion
    it "memoizes the instance" do
      expect(project.health.object_id).to be == project.health.object_id
    end
    # rubocop:enable RSpec/IdenticalEqualityAssertion
  end
end
