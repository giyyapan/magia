(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.StartScene = (function(_super) {

    __extends(StartScene, _super);

    function StartScene(game) {
      var playerData;
      StartScene.__super__.constructor.call(this);
      playerData = game.playerData;
    }

    StartScene.prototype.show = function() {};

    return StartScene;

  })(Scene);

}).call(this);
