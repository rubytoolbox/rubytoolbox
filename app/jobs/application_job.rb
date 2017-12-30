# frozen_string_literal: true

class ApplicationJob
  include Sidekiq::Worker
end
