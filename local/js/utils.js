(function() {
  var name;

  window.Utils = {
    setCSS3Attr: function(dom, name, value) {
      var J, obj;
      J = $(dom);
      obj = {};
      obj["" + name] = value;
      obj["-webkit-" + name] = value;
      obj["-o-" + name] = value;
      obj["-ms-" + name] = value;
      obj["-moz-" + name] = value;
      return J.css(obj);
    }
  };

  for (name in Suzaku.Utils) {
    window.Utils[name] = Suzaku.Utils[name];
  }

}).call(this);
