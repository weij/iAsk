
$(document).ready(function() {
  var $body = $(document.body);
	$('article:even').addClass("article_even");
	
	if (!("placeholder" in document.createElement("input"))) {
  	$('input[placeholder]').focus(function() {
      var input = $(this);
      if (input.val() == input.attr('placeholder')) {
        input.val('');
        input.removeClass('placeholder');
        if (input.attr('type') == 'password') {
          input.attr('origin_type', 'password')
          input.attr('type', 'text')
        }
      }
    }).blur(function() {
      var input = $(this);
      if (input.val() == '' || input.val() == input.attr('placeholder')) {
        input.addClass('placeholder');
        input.val(input.attr('placeholder'));
        if (input.attr('origin_type') == 'password') {
          input.attr('type', 'password')
        }
      }
    }).blur();
  }
  
  Loader.initialize($body, true);
});
