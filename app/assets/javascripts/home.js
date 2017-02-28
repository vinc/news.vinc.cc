$(document).on('turbolinks:load', function() {
  $('.card').each(function() {
    var card = $(this);
    var permalink = $('.card-permalink', card).attr('href');

    if (store.get(permalink)) {
      card.addClass('card-read');
    }
  });

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
});
