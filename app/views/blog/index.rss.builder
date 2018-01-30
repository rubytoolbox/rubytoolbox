# frozen_string_literal: true

xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title site_name
    xml.description description
    xml.link request.base_url
    xml.tag! "atom:link", href: feed_url, rel: "self", type: "application/rss+xml"

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description post.body_html
        xml.pubDate post.published_on.rfc822
        xml.link blog_post_url(post)
        xml.guid blog_post_url(post)
      end
    end
  end
end
