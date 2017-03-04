(function() {
  var pluralize = function(singular) {
    if (singular.endsWith('y')) {
      return singular.slice(0, -1) + 'ies';
    } else {
      return singular + 's';
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
      syncStore(data);
    }
  });

  var getModel = function(action) {
    switch (action) {
    case 'read':
    case 'unread':
    case 'list_permalinks':
      return 'permalink';
    case 'save':
    case 'unsave':
    case 'list_queries':
      return 'query';
    }
  };

  var syncStore = function(data) {
    var model = getModel(data.action);

    console.debug('sync ' + model + ' ' + data.action + ' with store');

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

    var value = plaintext.slice(start.length);
    $(document).trigger(data.action, value);
  };

  var request = function(action, data) {
    var type;
    switch (action) {
    case 'list_queries':
    case 'list_permalinks':
      type = 'GET';
      break;
    case 'save':
    case 'read':
      type = 'POST';
      break;
    case 'unsave':
    case 'unread':
      type = 'DELETE';
      break;
    }

    var model = getModel(action);
    var path;
    switch (type) {
    case 'DELETE':
      path = '/user/' + pluralize(model) + '/' + data.id + '.json';
      break;
    default:
      path = '/user/' + pluralize(model) + '.json';
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

    settings.data[model] = data;

    console.debug(['request', action, model].join(' '));
    return $.ajax(path, settings);
  };

  $(document).on('turbolinks:load', function() {
    request('list_permalinks').then(function(data) {
      console.debug('received permalinks list');
      (data || []).forEach(function(item) {
        console.debug('received read');

        item.action = 'read';
        syncStore(item);
      });
    });

    request('list_queries').then(function(data) {
      console.debug('received queries list');
      (data || []).forEach(function(item) {
        console.debug('received save');

        item.action = 'save';
        syncStore(item);
      });
    });
  });

  $(document).on('sync', function(event, action, value) {
    if (!action || !value) {
      return console.error('Error: sync called with empty params');
    }

    var model = getModel(action);
    var plaintext = model + ':' + value;

    console.debug(['sync', action, model].join(' '));

    switch (action) {
    case 'read':
    case 'save':
      store.set(plaintext, '');

      var params = {};
      var ciphertext = CryptoJS.AES.encrypt(plaintext, passphrase).toString();

      params['encrypted_' + model] = ciphertext;
      request(action, params).done(function(data) {
        store.set(plaintext, data.id);
      });
      break;
    case 'unread':
    case 'unsave':
      var id = store.remove(plaintext);

      if (id) {
        request(action, { id: id });
      }
      break;
    }
  });
}).call(this);
