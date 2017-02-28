module SearchHelper
  def link_to_search(query)
    link_to(query, search_path(q: query))
  end
end
