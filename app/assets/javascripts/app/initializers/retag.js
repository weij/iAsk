$(document).ready(function() {
  $('.retag-link').live('click',function(){
    var link = $(this);
    var tag_list = link.parent('.retag').parents('.main-content').children('.tag-list');
    link.parent('.retag').hide();
    tag_list.find('.tag').parent('li').hide();
    tag_list.find('.tag:parent').css('border', 'none');
    $.ajax({
      dataType: "json",
      type: "GET",
      url : link.attr('href'),
      extraParams : { 'format' : 'js'},
      success: function(data) {
        if(data.success){
          tag_list.before(data.html);
          $(".chosen-retag").ajaxChosen({
            method: 'GET',
            url: '/questions/tags_for_autocomplete.js',
            dataType: 'json'
          }, function (data) {
            var terms = {};
            $.each(data, function (i, val) {
              terms[val["value"]] = val["caption"];
            });

            return terms;
          });
        } else {
            Messages.show(data.message, "error");
            if(data.status == "unauthenticate") {
              window.location="/users/login"
            }
        }
      }
    });
    return false;
  });

  $('.retag-form').live('submit', function() {
    form = $(this);
    var button = form.find('input[type=submit]');
    button.attr('disabled', true);
    $.ajax({url: form.attr("action")+'.js',
      dataType: "json",
      type: "POST",
      data: form.serialize()+"&format=js",
      beforeSend: function(jqXHR, settings){

      },
      success: function(data, textStatus) {
          if(data.success) {
              var tags = $.map(data.tags, function(n){
                return '<li><a class="tag" rel="tag" href="/questions/tags/'+n+'">'+n+'</a></li>'
              })
              form.next('.tag-list').find('li>.tag').parent('li').remove();
              form.next('.tag-list').prepend($.unique(tags).join(''));
              form.remove();
              $('.retag').show();
              Messages.show(data.message, "notice");
          } else {
              Messages.show(data.message, "error")
              if(data.status == "unauthenticate") {
                  window.location="/users/login";
              }
          }
      },
      error: Messages.ajax_error_handler,
      complete: function(XMLHttpRequest, textStatus) {
        button.attr('disabled', false);
      }
    });
    return false;
  });

  $('.cancel-retag').live('click', function(){
      var link = $(this);
      var form = link.parents('form');
      var toolbar = form.parent('.main-content');
      form.next('.tag-list').find('.tag').parent('li').show();
      toolbar.find('.retag').show();
      form.remove();
      return false;
  });
});
