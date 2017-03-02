$(document).on('turbolinks:load', function() {
  var newSyncId = $('.form-sync input[name=sync_id]').val(); // Given by server
  var syncId = store.get('sync_id');
  var passphrase = store.get('passphrase');

  // syncId should be an hex string with the same size as newSyncId
  var validate = function(syncId, newSyncId) {
    return syncId && syncId.match('^[0-9a-h]{' + newSyncId.length + '}$');
  };

  // Use sync_id from local storage or the new one given by the server
  if (validate(syncId, newSyncId)) {
    $('.form-sync input[name=sync_id]').val(syncId);
  } else {
    store.set('sync_id', newSyncId);
  }

  if (passphrase) {
    $('.form-sync input[name=passphrase]').val(passphrase);
  }
  
  var updateSyncId = function() {
    console.debug('updating sync_id');
    syncId = $(this).val();
    if (!validate(syncId, newSyncId)) {
      syncId = newSyncId;
      $(this).val(newSyncId);
    }
    store.set('sync_id', syncId);
  };
  var updatePassphrase = function() {
    console.debug('updating passphrase');
    passphrase = $(this).val();
    store.set('passphrase', passphrase);
  };

  $('.form-sync input[name=sync_id]').on('change', updateSyncId);
  $('.form-sync input[name=passphrase]').on('change', updatePassphrase);
  $('.form-sync').on('submit', function(e) {
    updateSyncId();
    updatePassphrase();
    e.preventDefault();
  });
});
