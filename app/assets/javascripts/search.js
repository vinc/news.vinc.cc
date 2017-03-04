$(document).on('turbolinks:load', function() {
  // Hide all read items on load
  $('.card').each(function() {
    var card = $(this);
    var permalink = $('.card-permalink', card).attr('href');

    if (store.get(permalink)) {
      card.addClass('card-read');
    }
  });

  // Mark an item as read or unread
  $('.card > .card-header').click(function(e) {
    if (e.target.nodeName == 'DIV') {
      var card = $(this).parent();
      var permalink = $('.card-permalink', card).attr('href');

      if (card.hasClass('card-read')) {
        card.removeClass('card-read');
        card.trigger('sync-unread');
      } else {
        card.addClass('card-read');
        card.trigger('sync-read');
      }
    }
  });

  var query = $("input[name=q]").val();
  var saveButton = $("#save-query");

  var start = 'query:';
  var queries = store.keys().
    filter(function(key) { return key.startsWith(start); }).
    map(function(key) { return key.slice(start.length); }) || [];


  if (store.get('query:' + query)) {
    saveButton.html("Unsave");
  } else {
    saveButton.html("Save");
  }

  var savedDiv = $('.saved-queries');
  var suggestedDiv = $('.suggested-queries');

  // Replace suggested queries by saved queries on the home page
  console.debug(queries);
  if ($('body#home').length && savedDiv.length && queries.length) {
    $('ul', savedDiv).html(''); // NOTE: required by turbolink on history back
    queries.sort().forEach(function(query) {
      $('ul', savedDiv).append('<li><a href="/search?q=' + query + '">' + query + '</a></li>');
    });
    suggestedDiv.hide();
    savedDiv.show();
  }

  // Save or unsave a query
  saveButton.click(function() {
    var key = 'query:' + query;
    if (store.get(key)) {
      $(document).trigger('sync-unsave', query);
      $(".alert-success").html("Query successfuly unsaved").show();
      saveButton.html("Save");
    } else {
      $(document).trigger('sync-save', query);
      $(".alert-success").html("Query successfuly saved").show();
      saveButton.html("Unsave");
    }
  });
});
