$(document).on('turbolinks:load', function() {
  var syncId = store.get('sync_id');
  var passphrase = store.get('passphrase');

  if (syncId) {
    $('.form-sync input[name=sync_id]').val(syncId);
  } else {
    store.set('sync_id', $('.form-sync input[name=sync_id]').val());
  }

  if (passphrase) {
    $('.form-sync input[name=passphrase]').val(passphrase);
  }
  
  var updateSyncId = function() {
    console.debug('updating sync_id');
    syncId = $(this).val();
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
