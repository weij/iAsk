Users = function() {
  var self = this;


  $(".users-controller .toggle-action").on("ajax:success", function(xhr, data, status) {      
    if(data.success) {
      var link = $(this);
      var href = link.attr('href'), text = link.data('ujs:enable-with');
      var dataUndo = link.data('undo'), dataText = link.data('text');
      var img = link.children('img');
      var counter = $(link.data('counter'));

      //alert(text+"  "+dataText);
      link.attr({href: dataUndo});
      

      if(dataText && $.trim(dataText)!=''){
        link.text(dataText);
        link.data('ujs:enable-with', dataText);
        link.data({'undo': href, 'text': text});
      }
      

      img.attr({src: img.data('src'), 'data-src': img.attr('src')});
      if(typeof(link.data('increment'))!='undefined') {

        counter.text(parseFloat($.trim(counter.text()))+link.data('increment'));
      }

      if(text=="+ Follow user"){
        var count=parseInt($('li.followers_count strong').text())+1;
        $('li.followers_count strong').text(count);
      } else if(text=="- Unfollow user"){
        var count=parseInt($('li.followers_count strong').text())-1;
        $('li.followers_count strong').text(count);
      } 
      Messages.show(data.message, "notice");
    }
  });

  function initialize($body) {
    if($body.hasClass("index")) {
      Users.initializeOnIndex($body);
    } else if($body.hasClass("edit")) {
      Networks.initialize($body);
    }
  }

  function initializeOnEdit($body) {
    if($body.hasClass("index")) {
      Users.initialize_on_index($body);
    } else if($body.hasClass("edit")) {
      Networks.initialize($body);
    }
  }

  function initializeOnIndex($body) {
    $("#filter_users input[type=submit]").remove();

    $("#filter_users").searcher({ url : "/users.js",
                                target : $("#users"),
                                behaviour : "live",
                                timeout : 500,
                                extraParams : { 'format' : 'js' },
                                success: function(data) {
                                  $('#additional_info .pagination').html(data.pagination)
                                }
    });
  }

  function initializeOnShow($body) {
    $('#user_language').chosen();
    $('#user_timezone').chosen();
    $('#user_preferred_languages').chosen();
  }

  return {
    initialize:initialize,
    initializeOnIndex:initializeOnIndex,
    initializeOnShow:initializeOnShow
  }
}();
