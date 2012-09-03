
$(document).ready(function() {
  var $body = $(document.body);
	$('article:even').addClass("article_even");
	
	if (!("placeholder" in document.createElement("input"))) {
  	$('input[placeholder]').focus(function() {
      var input = $(this);
      if (input.val() == input.attr('placeholder')) {
        input.val('');
        input.removeClass('placeholder');
      }
    }).blur(function() {
      var input = $(this);
      if (input.val() == '' || input.val() == input.attr('placeholder')) {
        input.addClass('placeholder');
        input.val(input.attr('placeholder'));
      }
    }).blur();
  }
  
  Loader.initialize($body, true);
});
