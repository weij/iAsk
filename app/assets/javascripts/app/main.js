
$(document).ready(function() {
  var $body = $(document.body);
	$('article:even').addClass("article_even");
	
	var supportPlaceHolder = ("placeholder" in document.createElement("input"));
	if (!supportPlaceHolder) {
	  $(':password[placeholder]').each(function(){
	    var password = $(this);
	    var fakeNode = $(this.outerHTML.replace(/type=(['"])?password\1/gi, 'type=$1text$1'));
	    fakeNode.insertBefore(password).focus(function(){
        password.show();
        $(this).hide();
      });
      password.blur(function(){
        if(password.val() == ''){
          fakeNode.show();
          $(this).hide();
        }
      }).blur();
	  });
	  
  	$(':text[placeholder]').focus(function() {
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
	
	$('.search_box,:password').val('');
	
	
	Loader.initialize($body, true);
});

