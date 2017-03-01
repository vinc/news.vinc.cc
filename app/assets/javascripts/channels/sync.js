var secureRandomToken = function(size) {
  var array = new Uint32Array(size / 8);

  window.crypto.getRandomValues(array);

  return array.reduce(function(s, n) {
    return s + n.toString(16);
  }, '');
};

var id = store.get('id');

if (!id) {
  id = secureRandomToken(32);
  store.set('id', id);
}

App.sync = App.cable.subscriptions.create({ channel: 'SyncChannel', id: id }, {
  connected: function(data) {
    console.log('sending sync');
    App.sync.send({
      action: 'sync'
    });
  },
  received: function(data) {
    if (data.action === 'sync') {
      console.log('received sync');
      store.each(function(key, value) {
        if (typeof key === 'string' && key.startsWith('http')) {
          console.log('sending read ' + key);
          App.sync.send({
            action: 'read',
            url: key
          });
        }
      });
    }

    var permalink = data.url;
    var card = $('.card .card-permalink[href="' + permalink + '"]').parents('.card');
    if (store.get(permalink)) {
      if (data.action === 'unread') {
        console.log('received unread ' + permalink);
        store.remove(permalink);
        card.removeClass('card-read');
      }
    } else {
      if (data.action === 'read') {
        console.log('received read ' + permalink);
        store.set(permalink, +new Date());
        card.addClass('card-read');
      }
    }
  }
});

$(document).on('turbolinks:load', function() {
  $('.card').on('sync-read', function() {
    var permalink = $('.card-permalink', $(this)).attr('href');

    store.set(permalink, +new Date());

    console.log('sending read ' + permalink);
    App.sync.send({
      action: 'read',
      url: permalink
    });
  });

  $('.card').on('sync-unread', function() {
    var permalink = $('.card-permalink', $(this)).attr('href');

    store.remove(permalink);

    console.log('sending unread ' + permalink);
    App.sync.send({
      action: 'unread',
      url: permalink
    });
  });
});
