atom_feed do |feed|
  feed.title("News from #{@query}")
  feed.updated(Time.zone.now)

  @results.each do |item|
    feed.entry(item, { id: item.via, url: item.via }) do |entry|
      entry.title(item.title)
      entry.content(item.html) if item.html
      entry.link(item.url, { rel: 'related' }) if item.url

      entry.author do |author|
        author.name(item.author) if item.author
      end
    end
  end
end
