# frozen_string_literal: true

class GithubRepo < ApplicationRecord
  self.primary_key = :path

  has_many :projects,
           primary_key: :path,
           foreign_key: :github_repo_path,
           inverse_of: :github_repo,
           dependent: :nullify
end
