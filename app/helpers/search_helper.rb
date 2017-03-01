module SearchHelper
  # Create a custom links for queries
  #
  # NOTE: `highlight_filters` and `highlight_alnums` should only be used with
  # query containing no user inputs because the title needs to be `html_safe`.
  def link_to_search(query, highlight_filters: false, highlight_alnums: false)
    title = query.split.map do |word|
      word = "<strong>#{word}</strong>" if highlight_alnums && word[/\w+/] == word
      word = "<strong>#{word}</strong>" if highlight_filters && word[/\w+:\w+/] == word
      word
    end.join(" ")

    title = title.html_safe if highlight_filters || highlight_alnums

    link_to(title, search_path(q: query))
  end
end
