// Generated by CoffeeScript 1.6.3
(function() {
  var FirstFloor, SecondFloor,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  FirstFloor = (function(_super) {
    __extends(FirstFloor, _super);

    function FirstFloor(stage) {
      var _this = this;
      this.stage = stage;
      FirstFloor.__super__.constructor.call(this);
      this.menu = new Menu(Res.tpls["home-1st-floor"]);
      this.setImg(Res.imgs.homeDown);
      this.menu.UI.upstairs.onclick = function() {
        return _this.emit("goUp");
      };
    }

    FirstFloor.prototype.moveDown = function(callback) {
      var s;
      s = Utils.getSize();
      this.transform.rotate = 0;
      return this.animate({
        y: s.height,
        "transform.rotate": 0.5,
        "transform.opacity": 0
      }, "normal", "swing", callback);
    };

    FirstFloor.prototype.moveUp = function(callback) {
      return this.animate({
        y: 0,
        "transform.rotate": 0,
        "transform.opacity": 1
      }, "normal", "swing", callback);
    };

    FirstFloor.prototype.show = function() {
      var _this = this;
      this.menu.hide();
      return this.fadeIn("fast", function() {
        return _this.menu.show();
      });
    };

    return FirstFloor;

  })(Layer);

  SecondFloor = (function(_super) {
    __extends(SecondFloor, _super);

    function SecondFloor(stage) {
      var _this = this;
      this.stage = stage;
      SecondFloor.__super__.constructor.call(this);
      this.y = -Utils.getSize().height;
      this.menu = new Menu(Res.tpls["home-2nd-floor"]);
      this.setImg(Res.imgs.homeUp);
      this.menu.UI.downstairs.onclick = function() {
        return _this.emit("goDown");
      };
    }

    SecondFloor.prototype.moveDown = function(callback) {
      return this.animate({
        y: 0
      }, "normal", "swing", callback);
    };

    SecondFloor.prototype.moveUp = function(callback) {
      var s;
      s = Utils.getSize();
      return this.animate({
        y: -s.height
      }, "normal", "swing", callback);
    };

    return SecondFloor;

  })(Layer);

  window.Home = (function(_super) {
    __extends(Home, _super);

    function Home(game) {
      var playerData,
        _this = this;
      Home.__super__.constructor.call(this);
      this.game = game;
      playerData = game.playerData;
      this.camera = new Camera();
      this.firstFloor = new FirstFloor(playerData);
      this.secondFloor = new SecondFloor(playerData);
      this.drawQueueAddAfter(this.secondFloor, this.firstFloor);
      this.firstFloor.on("goUp", function() {
        _this.firstFloor.menu.hide();
        _this.firstFloor.moveDown();
        return _this.secondFloor.moveDown(function() {
          return _this.secondFloor.menu.show();
        });
      });
      this.secondFloor.on("goDown", function() {
        _this.secondFloor.menu.hide();
        _this.secondFloor.moveUp();
        return _this.firstFloor.moveUp(function() {
          return _this.firstFloor.menu.show();
        });
      });
      this.firstFloor.show();
    }

    Home.prototype.tick = function() {};

    Home.prototype.draw = function() {};

    return Home;

  })(Stage);

}).call(this);
