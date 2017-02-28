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
        store.remove(permalink);
        card.removeClass('card-read');
      } else {
        store.set(permalink, +new Date());
        card.addClass('card-read');
      }
    }
  });

  var queries = store.get('queries') || [];
  var query = $("input[name=q]").val();
  var saveButton = $("#save-query");

  if (queries.indexOf(query) === -1) {
    saveButton.html("Save");
  } else {
    saveButton.html("Unsave");
  }

  var savedDiv = $('.saved-queries');
  var suggestedDiv = $('.suggested-queries');

  // Replace suggested queries by saved queries
  if (savedDiv.length && queries.length) {
    queries.sort().forEach(function(query) {
      $('ul', savedDiv).append('<li><a href="/?q=' + query + '">' + query + '</a></li>');
    });
    suggestedDiv.hide();
    savedDiv.show();
  }

  // Save or unsave a query
  saveButton.click(function() {
    var queries = store.get('queries') || [];
    var i = queries.indexOf(query);

    if (i === -1) {
      queries.push(query);
      $(".alert-success").html("Query successfuly saved").show();
      saveButton.html("Unsave");
    } else {
      queries.splice(i, 1);
      $(".alert-success").html("Query successfuly unsaved").show();
      saveButton.html("Save");
    }

    store.set('queries', queries);
  });
});
