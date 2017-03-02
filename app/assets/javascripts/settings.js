$(document).on('turbolinks:load', function() {
  var form = $('.form-sync');
  var inputSyncId = $('input[name=sync_id]', form);
  var inputPassphrase = $('input[name=passphrase]', form);

  var newSyncId = inputSyncId.val(); // Given by server
  var syncId = store.get('sync_id');
  var passphrase = store.get('passphrase');

  // syncId should be an hex string with the same size as newSyncId
  var validate = function(syncId, newSyncId) {
    return syncId && syncId.match('^[0-9a-h]{' + newSyncId.length + '}$');
  };

  // Use sync_id from local storage or the new one given by the server
  if (validate(syncId, newSyncId)) {
    inputSyncId.val(syncId);
  } else {
    store.set('sync_id', newSyncId);
  }

  if (passphrase) {
    inputPassphrase.val(passphrase);
  }
  
  var updateSyncId = function() {
    console.debug('updating sync_id');
    syncId = inputSyncId.val();
    if (!validate(syncId, newSyncId)) {
      syncId = newSyncId;
      inputSyncId.val(newSyncId);
    }
    store.set('sync_id', syncId);
  };

  var updatePassphrase = function() {
    console.debug('updating passphrase');
    passphrase = inputPassphrase.val();
    store.set('passphrase', passphrase);
  };

  inputSyncId.on('change', updateSyncId);
  inputPassphrase.on('change', updatePassphrase);
  form.on('submit', function(e) {
    e.preventDefault();
    updateSyncId();
    updatePassphrase();
  });
});
