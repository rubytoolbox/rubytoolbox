# frozen_string_literal: true

module DocsHelper
  def highlight_json(content)
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexers::JSON.new
    formatter.format lexer.lex(content)
  end

  def comparisons_api_sample_response(*permalinks)
    projects = Project.where(permalink: permalinks)
                      .includes_associations

    ProjectBlueprint.render_as_hash projects, root: :projects, root_url: request_root_url
  end

  def request_root_url
    request.protocol + request.host_with_port
  end
end
