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
      console.debug(data);
      console.debug('received ' + data.action);

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
          store.set(permalink, +new Date());
          card.addClass('card-read');
        }
      }
    }
  });

  var syncPermalink = function(ciphertext, action) {
    var type = 'PUT';
    var path = '/user/' + action + '.json';
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
        permalink: {
          encrypted_permalink: ciphertext
        }
      }
    };
    console.debug('sending ' + action);
    $.ajax(path, settings);
  };

  $(document).on('turbolinks:load', function() {
    $('.card').on('sync-read', function() {
      var permalink = $('.card-permalink', $(this)).attr('href');
      var ciphertext = CryptoJS.AES.encrypt(permalink, passphrase).toString();

      store.set(permalink, +new Date());
      syncPermalink(ciphertext, 'read');
    });

    $('.card').on('sync-unread', function() {
      var permalink = $('.card-permalink', $(this)).attr('href');
      var ciphertext = CryptoJS.AES.encrypt(permalink, passphrase).toString();

      store.remove(permalink);
      syncPermalink(ciphertext, 'unread');
    });
  });
}).call(this);
