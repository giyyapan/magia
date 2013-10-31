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
      this.camera = new Camera();
      this.menu = new Menu(Res.tpls["home-1st-floor"]);
      this.setImg(Res.imgs.homeDown);
      this.menu.UI.upstairs.onclick = function() {
        return _this.emit("goUp");
      };
      this.menu.UI.exit.onclick = function() {
        return _this.emit("exit");
      };
    }

    FirstFloor.prototype.moveDown = function(callback) {
      var s;
      s = Utils.getSize();
      this.transform.rotate = 0;
      return this.animate({
        y: s.height
      }, "normal", "swing", callback);
    };

    FirstFloor.prototype.moveUp = function(callback) {
      return this.animate({
        y: 0
      }, "normal", "swing", callback);
    };

    FirstFloor.prototype.show = function() {
      this.fadeIn("fast");
      return this.menu.show();
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
      this.camera = this.stage.camera;
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
      var _this = this;
      Home.__super__.constructor.call(this);
      this.game = game;
      this.camera = new Camera();
      this.firstFloor = new FirstFloor(this);
      this.secondFloor = new SecondFloor(this);
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
      this.firstFloor.on("exit", function() {
        _this.clearDrawQueue();
        return _this.game.switchStage("worldMap");
      });
      this.firstFloor.show();
    }

    Home.prototype.tick = function() {};

    return Home;

  })(Stage);

}).call(this);
