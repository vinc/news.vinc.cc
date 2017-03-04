$(document).on('turbolinks:load', function() {
  $('.navbar input[name=q]').focusin(function() {
    $('.navbar').addClass('search-focused');
  });

  $('.navbar input[name=q]').focusout(function() {
    $('.navbar').removeClass('search-focused');
  });
});
