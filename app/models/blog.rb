# frozen_string_literal: true

class Blog
  class Post
    attr_accessor :permalink, :title, :published_on, :body_html
    private :permalink=, :title=, :published_on=, :body_html=

    def initialize(permalink:, title:, published_on:, body_html:)
      self.permalink = permalink
      self.title = title
      self.published_on = published_on
      self.body_html = body_html
    end

    def slug
      "#{published_on}/#{permalink}"
    end

    def ==(other)
      slug == other.slug
    end
  end

  class PostLoader
    attr_accessor :path
    private :path=

    def initialize(path:)
      self.path = path
    end

    def post
      Post.new(
        published_on: published_on,
        permalink: permalink,
        title: title,
        body_html: body_html
      )
    end

    def published_on
      Date.parse(path_data[1])
    end

    def permalink
      path_data[2].presence&.strip
    end

    def title
      html_doc.xpath("//h1[1]").text
    end

    def body_html
      html_doc.xpath("//h1[1]/following-sibling::*").to_s
    end

    private

    def path_data
      @path_data ||= File.basename(path).match(/(\d{4}\-\d{2}\-\d{2})\-([^\.]+)/)
    end

    def html_content
      @html_content ||= markdown_renderer.render(File.read(path))
    end

    def html_doc
      @html_doc ||= Nokogiri::HTML.parse(html_content)
    end

    def markdown_renderer
      Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    end
  end

  attr_accessor :root, :cache
  private :root=, :cache=

  def initialize(root:, cache: false)
    self.root = Pathname.new(root)
    self.cache = cache
  end

  def posts
    if cache
      @posts ||= load_posts
    else
      load_posts
    end
  end

  def find(slug)
    post = posts.find { |p| slug == p.slug }
    return post if post
    raise ActiveRecord::RecordNotFound, "No blog post matching #{slug.inspect} found"
  end

  private

  def load_posts
    posts = []
    Dir[root.join("*.md")].each do |path|
      posts << PostLoader.new(path: path).post
    end
    posts.sort_by(&:published_on).reverse
  end
end
