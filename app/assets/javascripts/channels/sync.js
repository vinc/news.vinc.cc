(function() {
  var passphrase = store.get('passphrase');
  var config = {
    channel: 'SyncChannel',
    auth_id: store.get('auth_id')
  };

  if (!passphrase || !config.auth_id) {
    return;
  }

  App.sync = App.cable.subscriptions.create(config, {
    received: function(data) {
      console.debug('received ' + data.action);

      var id = data.id;
      var ciphertext = data.encrypted_permalink;
      var bytes = CryptoJS.AES.decrypt(ciphertext, passphrase);
      var permalink;
      try {
        permalink = bytes.toString(CryptoJS.enc.Utf8);
      } catch(e) {
        return console.error('Error decrypting permalink');
      }
      if (!permalink.startsWith('http')) {
        return console.error('Error decrypting permalink');
      }

      var card = $('.card .card-permalink[href="' + permalink + '"]').parents('.card');
      if (store.get(permalink)) {
        if (data.action === 'unread') {
          store.remove(permalink);
          card.removeClass('card-read');
        }
      } else {
        if (data.action === 'read') {
          store.set(permalink, id);
          card.addClass('card-read');
        }
      }
    }
  });

  var syncPermalink = function(action, data) {
    var type, path, dataType;
    switch (action) {
    case 'list':
      type = 'GET';
      path = '/user/permalinks.json';
      break;
    case 'read':
      type = 'POST';
      path = '/user/permalinks.json';
      break;
    case 'unread':
      type = 'DELETE';
      path = '/user/permalinks/' + data.id + '.json';
      break;
    }

    var key = store.get('auth_secret');
    var msg = type + ' ' + path;
    var mac = CryptoJS.HmacSHA256(msg, key);

    var token = 'Bearer token=' + store.get('auth_id') + ':' + mac;
    var settings = {
      type: type,
      headers: {
        authorization: token
      },
      data: {
        permalink: data
      }
    };

    console.debug('sending ' + action);
    return $.ajax(path, settings);
  };

  $(document).on('turbolinks:load', function() {
    syncPermalink('list').then(function(data) {
      data.forEach(function(item) {
        console.debug('received read');

        var id = item.id;
        var ciphertext = item.encrypted_permalink;
        var bytes = CryptoJS.AES.decrypt(ciphertext, passphrase);
        var permalink;
        try {
          permalink = bytes.toString(CryptoJS.enc.Utf8);
        } catch(e) {
          return console.error('Error decrypting permalink');
        }
        if (!permalink.startsWith('http')) {
          return console.error('Error decrypting permalink');
        }

        var card = $('.card .card-permalink[href="' + permalink + '"]').parents('.card');
        store.set(permalink, id);
        card.addClass('card-read');
      });
    });

    $('.card').on('sync-read', function() {
      var permalink = $('.card-permalink', $(this)).attr('href');
      var ciphertext = CryptoJS.AES.encrypt(permalink, passphrase).toString();

      syncPermalink('read', { encrypted_permalink: ciphertext }).done(function(data) {
        store.set(permalink, data.id);
      });
    });

    $('.card').on('sync-unread', function() {
      var permalink = $('.card-permalink', $(this)).attr('href');
      var ciphertext = CryptoJS.AES.encrypt(permalink, passphrase).toString();

      syncPermalink('unread', { id: store.get(permalink) }).always(function() {
        store.remove(permalink);
      });
    });
  });
}).call(this);
