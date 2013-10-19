(function() {
  var MenuButton,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Drawable = (function() {

    function Drawable(x, y, width, height) {
      this.x = x;
      this.y = y;
      this.width = width;
      this.height = height;
    }

    Drawable.prototype.draw = function(context) {
      context.fillStype("black");
      return context.fillRect(this.x, this.y, this.width, this.height);
    };

    return Drawable;

  })();

  window.Scene = (function(_super) {

    __extends(Scene, _super);

    function Scene() {}

    return Scene;

  })(Drawable);

  window.Layer = (function(_super) {

    __extends(Layer, _super);

    function Layer() {}

    return Layer;

  })(Drawable);

  MenuButton = (function(_super) {

    __extends(MenuButton, _super);

    function MenuButton() {}

    return MenuButton;

  })(Suzaku.Widget);

  window.Menu = (function(_super) {

    __extends(Menu, _super);

    function Menu() {}

    return Menu;

  })(Suzaku.Widget);

}).call(this);
