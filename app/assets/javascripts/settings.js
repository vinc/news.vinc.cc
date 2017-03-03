$(document).on('turbolinks:load', function() {
  var form = $('.form-sync');

  var authId = store.get('auth_id');
  var authSecret = store.get('auth_secret');
  var passphrase = store.get('passphrase');

  $('[name=auth_id]', form).val(authId);
  $('[name=auth_secret]', form).val(authSecret);
  $('[name=passphrase]', form).val(passphrase);
  
  var updateAuthId = function() {
    console.debug('updating auth_id');
    authId = $('[name=auth_id]', form).val();
    store.set('auth_id', authId);
  };
  var updateAuthSecret = function() {
    console.debug('updating auth_secret');
    authSecret = $('[name=auth_secret]', form).val();
    store.set('auth_secret', authSecret);
  };
  var updatePassphrase = function() {
    console.debug('updating passphrase');
    passphrase = $('[name=passphrase]', form).val();
    store.set('passphrase', passphrase);
  };

  $('[name=auth_id]', form).on('change', updateAuthId);
  $('[name=auth_secret]', form).on('change', updateAuthSecret);
  $('[name=passphrase]', form).on('change', updatePassphrase);

  form.on('submit', function(e) {
    e.preventDefault();

    updateAuthId();
    updateAuthSecret();
    updatePassphrase();

    location.reload();
  });

  $('button[name=create-account]', form).click(function() {
    $.ajax('/user.json', { type: 'POST' }).then(function(data) {
      store.set('auth_id', data.auth_id);
      store.set('auth_secret', data.auth_secret);

      $('input[name=auth_id]').val(data.auth_id);
      $('input[name=auth_secret]').val(data.auth_secret);
    });
  });
});
