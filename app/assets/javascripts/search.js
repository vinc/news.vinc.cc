var updateQueriesList = function() {
  if ($('body#home').length) {
    var savedDiv = $('.saved-queries');
    var suggestedDiv = $('.suggested-queries');

    var start = 'query:';
    var queries = store.keys().
      filter(function(key) { return key.startsWith(start); }).
      map(function(key) { return key.slice(start.length); }) || [];

    // Replace suggested queries by saved queries on the home page
    if (savedDiv.length && queries.length) {
      $('ul', savedDiv).html(''); // NOTE: required by turbolink on history back
      queries.sort().forEach(function(query) {
        $('ul', savedDiv).append('<li><a href="/search?q=' + encodeURIComponent(query) + '">' + query + '</a></li>');
      });
      suggestedDiv.hide();
      savedDiv.show();
    } else {
      suggestedDiv.show();
      savedDiv.hide();
    }
  }
};

$(document).on('turbolinks:load', function() {
  // Hide all read items on load
  $('.card').each(function() {
    var card = $(this);
    var permalink = card.data('url');

    // NOTE: value can be an id if synced to server, or an empty string
    if (store.get('permalink:' + permalink) !== null) {
      card.addClass('card-read');
    }
  });

  // Mark an item as read or unread
  $('.card > .card-header').click(function(e) {
    var card = $(this).parent();
    var permalink = card.data('url');

    if (card.hasClass('card-read')) {
      $(document).trigger('unread', permalink);
      $(document).trigger('sync', ['unread', permalink]);
    } else {
      $(document).trigger('read', permalink);
      $(document).trigger('sync', ['read', permalink]);
    }
  });

  var query = $("input[name=q]").val();
  var saveButton = $("#save-query");

  // NOTE: value can be an id if synced to server, or an empty string
  if (store.get('query:' + query) !== null) {
    saveButton.html("Unsave");
  } else {
    saveButton.html("Save");
  }

  updateQueriesList();

  // Save or unsave a query
  saveButton.click(function() {
    // NOTE: value can be an id if synced to server, or an empty string
    if (store.get('query:' + query) !== null) {
      $(document).trigger('unsave', query);
      $(document).trigger('sync', ['unsave', query]);
    } else {
      $(document).trigger('save', query);
      $(document).trigger('sync', ['save', query]);
    }
  });
});

$(document).on('save', function(event, query) {
  if ($("input[name=q]").val() == query) {
    var nextActionTitle = 'Unsave';

    if ($('#save-query').html() != nextActionTitle) {
      $(".alert-success").html("Query successfuly saved").show();
      $('#save-query').html(nextActionTitle);
    }
  } else {
    updateQueriesList();
  }
});

$(document).on('unsave', function(event, query) {
  if ($("input[name=q]").val() == query) {
    var nextActionTitle = 'Save';

    if ($('#save-query').html() != nextActionTitle) {
      $(".alert-success").html("Query successfuly unsaved").show();
      $('#save-query').html(nextActionTitle);
    }
  } else {
    updateQueriesList();
  }
});

$(document).on('read', function(event, permalink) {
  var card = $('.card[data-url="' + permalink + '"]');

  card.addClass('card-read');
});

$(document).on('unread', function(event, permalink) {
  var card = $('.card[data-url="' + permalink + '"]');

  card.removeClass('card-read');
});
