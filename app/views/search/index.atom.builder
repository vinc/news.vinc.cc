# frozen_string_literal: true

atom_feed do |feed|
  feed.title("News from #{@query}")
  feed.updated(Time.zone.now)
  feed.author do |author|
    author.name(@source)
  end

  @results.each do |item|
    feed.entry(item, id: item.via, url: item.via) do |entry|
      entry.title(item.title)
      entry.content(item.html, type: "html") if item.html
      entry.link(rel: "related", type: "text/html", href: item.url) if item.url

      if item.author
        entry.author do |author|
          author.name(item.author)
        end
      end
    end
  end
end
