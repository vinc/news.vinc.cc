(function() {
  var singular = function(plural) {
    if (plural.endsWith('ies')) {
      return plural.slice(0, -3) + 'y';
    } else {
      return plural.slice(0, -1);
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
      syncStore(data);
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

    var value = plaintext.slice(start.length);
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
    console.debug(settings);
    return $.ajax(path, settings);
  };

  $(document).on('turbolinks:load', function() {
    request('list permalinks').then(function(data) {
      console.debug('received permalinks list');
      (data || []).forEach(function(item) {
        console.debug('received read');

        item.action = 'read';
        syncStore(item);
      });
    });

    request('list queries').then(function(data) {
      console.debug('received queries list');
      (data || []).forEach(function(item) {
        console.debug('received save');

        item.action = 'save';
        syncStore(item);
      });
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

  $(document).on('sync-read', function(event, permalink) {
    var plaintext = 'permalink:' + permalink;
    var ciphertext = CryptoJS.AES.encrypt(plaintext, passphrase).toString();

    store.set(plaintext, '');
    request('read', { encrypted_permalink: ciphertext }).done(function(data) {
      store.set(plaintext, data.id);
    });
  });

  $(document).on('sync-unsave', function(event, query) {
    var plaintext = 'query:' + query;
    var id = store.remove(plaintext);

    request('save', { id: id });
  });

  $(document).on('sync-unread', function(event, permalink) {
    var plaintext = 'permalink:' + permalink;
    var id = store.remove(plaintext);

    request('unread', { id: id });
  });
}).call(this);
