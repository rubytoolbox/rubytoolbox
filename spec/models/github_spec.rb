# frozen_string_literal: true

require "rails_helper"

RSpec.describe Github, type: :model do
  describe ".detect_repo_name" do
    {
      [nil] => nil,
      [nil, ""] => nil,
      [nil, "", " "] => nil,
      [nil, "", "wat"] => nil,
      ["fakegithub.com/rails/rails"] => nil,
      ["http://github.com/{github_username}/{project_name}"] => nil,
      ["http://github.com/rails/rails"] => "rails/rails",
      ["foobar", "http://github.com/rails/rails"] => "rails/rails",
    }.each do |args, expected_name|
      it "is #{expected_name.inspect} when given #{args.inspect}" do
        expect(Github.detect_repo_name(*args)).to be == expected_name
      end
    end
  end
end
