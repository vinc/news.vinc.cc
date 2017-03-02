(function() {
  var passphrase = store.get('passphrase');
  var config = {
    channel: 'SyncChannel',
    sync_id: store.get('sync_id')
  };

  if (!passphrase || !config.sync_id) {
    return;
  }

  App.sync = App.cable.subscriptions.create(config, {
    connected: function(data) {
      App.sync.send({
        action: 'sync'
      });
    },
    received: function(data) {
      if (data.action === 'sync') {
        store.each(function(key, value) {
          if (typeof key === 'string' && key.startsWith('http')) {
            var permalink = key;
            var ciphertext = CryptoJS.AES.encrypt(permalink, passphrase).toString();

            App.sync.send({
              action: 'read',
              url: ciphertext
            });
          }
        });
      } else {
        var ciphertext = data.url;
        var bytes = CryptoJS.AES.decrypt(ciphertext, passphrase);
        var permalink = bytes.toString(CryptoJS.enc.Utf8);

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
    }
  });

  $(document).on('turbolinks:load', function() {
    $('.card').on('sync-read', function() {
      var permalink = $('.card-permalink', $(this)).attr('href');
      var ciphertext = CryptoJS.AES.encrypt(permalink, passphrase).toString();

      store.set(permalink, +new Date());

      App.sync.send({
        action: 'read',
        url: ciphertext
      });
    });

    $('.card').on('sync-unread', function() {
      var permalink = $('.card-permalink', $(this)).attr('href');
      var ciphertext = CryptoJS.AES.encrypt(permalink, passphrase).toString();

      store.remove(permalink);

      App.sync.send({
        action: 'unread',
        url: ciphertext
      });
    });
  });
}).call(this);
