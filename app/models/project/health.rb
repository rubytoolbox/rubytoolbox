# frozen_string_literal: true

#
# Creates a health assessment for given project instance based on health checks defined
# in Project::Health::Checks
#
class Project::Health
  class Status
    attr_accessor :key, :level, :icon, :check_block
    def initialize(key, level, icon, &check_block)
      self.key = key
      self.level = level
      self.icon = icon
      self.check_block = check_block

      raise ArgumentError, "Unknown level #{level}" unless %i[red yellow green].include? level
      raise I18n::MissingTranslation.new(I18n.locale, i18n_key) unless I18n.exists? i18n_key
    end

    def label
      I18n.t i18n_key
    end

    def applies?(project)
      !!check_block.call(project)
    end

    private

    def i18n_key
      "project_health.#{key}"
    end
  end

  HEALTHY_STATUS = Project::Health::Status.new(:healthy, :green, :heartbeat, &:present?)

  attr_accessor :project, :checks
  private :project=, :checks=

  def initialize(project)
    self.project = project
    self.checks = Checks::ALL
  end

  def status
    @status ||= checks.select { |check| check.applies? project }.presence || [HEALTHY_STATUS]
  end

  def overall_level
    return :red if status.any? { |status| status.level == :red }
    return :yellow if status.any? { |status| status.level == :yellow }

    :green
  end
end
