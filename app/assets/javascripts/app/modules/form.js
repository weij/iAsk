Form = function() {
  var self = this;

  function initialize() {
    if(!Modernizr.inputtypes.color) {
      $("input[type=color]").jPicker({
        window: {
          expandable: true,
          position: { x: 'screenCenter', y: 'center'}
        },
        images: { clientPath: '/images/jpicker/' }
      });
      $("input[type=color]").hide();
    } else {
      $('input[type=color]').change(function(){
        $(this).attr('value', $(this).val())
      });
    }
  }
  return {
    initialize:initialize
  }
}();
