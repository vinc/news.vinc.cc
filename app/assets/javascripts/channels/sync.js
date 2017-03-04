(function() {
  var singular = function(plural) {
    if (plural.endsWith('ies')) {
      return plural.slice(0, -3) + 'y';
    } else {
      return plural.slice(0, -2);
    }
  };

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

      if (data.action === 'read' || data.action === 'unread') {
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
      } else if (data.action === 'save' || data.action === 'unsave') {
        syncStore(data);
      }
    }
  });

  var syncStore = function(data) {
    var model;

    switch (data.action) {
    case 'read':
    case 'unread':
      model = 'permalink';
      break;
    case 'save':
    case 'unsave':
      model = 'query';
      break;
    }

    var id = data.id;
    var ciphertext = data['encrypted_' + model];
    var bytes = CryptoJS.AES.decrypt(ciphertext, passphrase);
    var plaintext;
    try {
      plaintext = bytes.toString(CryptoJS.enc.Utf8);
    } catch(e) {
      return console.error('Error decrypting ' + model);
    }
    var start = model + ':';
    if (!plaintext.startsWith(start)) {
      return console.error('Error decrypting ' + model);
    }

    var value = plaintext.slice(start.length, -1);
    $(document).trigger(data.action, value);

    switch (data.action) {
    case 'read':
    case 'save':
      store.set(plaintext, id);
      break;
    case 'unsave':
    case 'unread':
      store.remove(plaintext);
      break;
    }
  };

  var request = function(action, data) {
    var type, path, model;

    switch (action) {
    case 'list permalinks':
      type = 'GET';
      model = 'permalinks';
      break;
    case 'read':
      type = 'POST';
      model = 'permalinks';
      break;
    case 'unread':
      type = 'DELETE';
      model = 'permalinks';
      break;
    case 'list queries':
      type = 'GET';
      model = 'queries';
      break;
    case 'save':
      type = 'POST';
      model = 'queries';
      break;
    case 'unsave':
      type = 'DELETE';
      model = 'queries';
      break;
    }

    switch (type) {
    case 'DELETE':
      path = '/user/' + model + '/' + data.id + '.json';
      break;
    default:
      path = '/user/' + model + '.json';
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
      data: { }
    };

    settings.data[singular(model)] = data;

    console.debug('sending ' + action);
    return $.ajax(path, settings);
  };

  $(document).on('turbolinks:load', function() {
    request('list permalinks').then(function(data) {
      console.debug('received permalinks list');
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

    request('list queries').then(function(data) {
      console.debug('received queries list');
      (data || []).forEach(function(item) {
        console.debug('received save');

        var id = item.id;
        var ciphertext = item.encrypted_query;
        var bytes = CryptoJS.AES.decrypt(ciphertext, passphrase);
        var plaintext;
        try {
          plaintext = bytes.toString(CryptoJS.enc.Utf8);
        } catch(e) {
          return console.error('Error decrypting query');
        }
        var start = 'query:';
        if (!plaintext.startsWith(start)) {
          return console.error('Error decrypting query');
        }
        store.set(plaintext, id);
      });
    });

    $(document).on('sync-save', function(event, query) {
      var plaintext = 'query:' + query;
      var ciphertext = CryptoJS.AES.encrypt(plaintext, passphrase).toString();

      store.set(plaintext, '');
      request('save', { encrypted_query: ciphertext }).done(function(data) {
        store.set(plaintext, data.id);
      });
    });

    $(document).on('sync-unsave', function(event, query) {
      var plaintext = 'query:' + query;
      var id = store.remove(plaintext);

      request('save', { id: id });
    });

    $('.card').on('sync-read', function() {
      var permalink = $('.card-permalink', $(this)).attr('href');
      var ciphertext = CryptoJS.AES.encrypt(permalink, passphrase).toString();

      request('read', { encrypted_permalink: ciphertext }).done(function(data) {
        store.set(permalink, data.id);
      });
    });

    $('.card').on('sync-unread', function() {
      var permalink = $('.card-permalink', $(this)).attr('href');
      var ciphertext = CryptoJS.AES.encrypt(permalink, passphrase).toString();

      request('unread', { id: store.get(permalink) }).always(function() {
        store.remove(permalink);
      });
    });
  });
}).call(this);
