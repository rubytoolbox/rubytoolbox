# frozen_string_literal: true

class SearchesController < ApplicationController
  # Default upper bound (in milliseconds) on how long a single search
  # request's database queries may run before Postgres aborts them. This
  # keeps a pathological query from holding a web dyno until Heroku's 30s H12
  # request timeout fires. Override via the SEARCH_STATEMENT_TIMEOUT_MS env
  # var.
  DEFAULT_STATEMENT_TIMEOUT_MS = 5_000

  rescue_from ActiveRecord::QueryCanceled, with: :render_search_unavailable

  around_action :with_statement_timeout, only: :show

  before_action :reject_disabled_search, only: :show

  delegate :search_disabled?, :statement_timeout_ms, to: :class, private: true

  # Emergency killswitch: when the DISABLE_SEARCH env var is set, search is
  # turned off entirely. This lets us disable search through a config
  # var, without a deploy, if it is being abused and causing trouble,
  # i.e. see https://github.com/rubytoolbox/rubytoolbox/issues/1705
  def self.search_disabled?
    ENV["DISABLE_SEARCH"].present?
  end

  # Maximum runtime for search queries in milliseconds, configurable via the
  # SEARCH_STATEMENT_TIMEOUT_MS env var. Falls back to
  # DEFAULT_STATEMENT_TIMEOUT_MS when it is unset or not a positive integer.
  def self.statement_timeout_ms
    configured = ENV["SEARCH_STATEMENT_TIMEOUT_MS"].to_i
    configured.positive? ? configured : DEFAULT_STATEMENT_TIMEOUT_MS
  end

  def show
    @query = params[:q].presence
    return unless @query

    perform_search

    redirect_to_search_with_forks_included if should_redirect_to_included_forks?
  end

  def by_name
    render json: Project.suggest(params[:q])
  end

  private

  # Halts the request with an "unavailable" notice when the search killswitch
  # (DISABLE_SEARCH) is active, so no search is performed at all.
  def reject_disabled_search
    return unless search_disabled?

    @query = params[:q].presence
    render :unavailable, status: 503
  end

  # Bounds the database time a search request may consume so a runaway query
  # fails fast (raising ActiveRecord::QueryCanceled) instead of tying up a web
  # dyno until Heroku's request timeout. statement_timeout is reset afterwards
  # so the pooled connection does not carry the limit to other requests.
  def with_statement_timeout
    connection = ActiveRecord::Base.connection
    connection.execute "SET statement_timeout = #{connection.quote statement_timeout_ms}"
    yield
  ensure
    connection&.execute "RESET statement_timeout"
  end

  # Rendered when a search query is aborted by the statement timeout. Renders
  # the dedicated unavailable view (rather than the search relations, which
  # would re-run the slow query) and returns a 503 with a friendly notice.
  def render_search_unavailable
    @query ||= params[:q].presence
    render :unavailable, status: 503
  end

  def perform_search
    @search = Search.new @query, order: current_order, show_forks: show_forks?
    @projects = @search.projects.page params[:page]
    @display_mode = DisplayMode.new params[:display], default: "compact"
  end

  # If a user searches for some query but that search does not
  # yield any project results we automatically redirect to the
  # search with bugfix forks included. However this must only
  # happen if the show forks param is not set at all, otherwise
  # it becomes impossible to reduce the query back to "without forks" :)
  def should_redirect_to_included_forks?
    !show_forks? && !params.key?(:show_forks) && @projects.empty?
  end

  def redirect_to_search_with_forks_included
    redirect_to action:     :show,
                q:          @search.query,
                order:      current_order.ordered_by,
                show_forks: true
  end

  def show_forks?
    params[:show_forks].present? && params[:show_forks] == "true"
  end

  def current_order
    @current_order ||= Project::Order.new order: params[:order], directions: Project::Order::SEARCH_DIRECTIONS
  end
  helper_method :current_order
end
