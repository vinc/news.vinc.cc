$(document).on('turbolinks:load', function() {
  // https://newsapi.org/v1/sources?language=en
  var queries = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: '/search/autocomplete.json?q=%QUERY',
      wildcard: '%QUERY'
    }
  });

  $('input[name=q]').typeahead(
    {
      hint: true,
      highlight: true,
      minLength: 0
    },
    {
      name: 'queries',
      source: queries
    }
  );
});
