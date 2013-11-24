// Generated by CoffeeScript 1.6.3
(function() {
  var FirstFloor, Floor, HomeMenu, SecondFloor, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HomeMenu = (function(_super) {
    __extends(HomeMenu, _super);

    function HomeMenu(floor) {
      HomeMenu.__super__.constructor.call(this, Res.tpls['home-menu']);
      this.floor = floor;
    }

    HomeMenu.prototype.addFunctionBtn = function(name, x, y, width, height, callback) {
      return console.log("add function btn");
    };

    return HomeMenu;

  })(Menu);

  Floor = (function(_super) {
    __extends(Floor, _super);

    function Floor(home) {
      Floor.__super__.constructor.call(this, 0, 0);
      this.home = home;
      this.camera = new Camera();
      this.mainBg = null;
      this.drawQueueAdd(this.camera);
      this.layers = {};
      this.currentX = 0;
      this.initMenu();
      this.initLayers();
    }

    Floor.prototype.initLayers = function() {};

    Floor.prototype.initMenu = function() {
      var moveCallback, s,
        _this = this;
      s = Utils.getSize();
      this.menu = new HomeMenu;
      moveCallback = function() {
        var x;
        x = _this.currentX;
        delete _this.camera.lock;
        if (x === 0) {
          _this.menu.UI['move-left'].J.fadeOut(130);
        } else {
          _this.menu.UI['move-left'].J.fadeIn(130);
        }
        if (x === (_this.mainBg.width - s.width)) {
          return _this.menu.UI['move-right'].J.fadeOut(130);
        } else {
          return _this.menu.UI['move-right'].J.fadeIn(130);
        }
      };
      this.menu.UI['move-right'].onclick = function(evt) {
        var x;
        evt.stopPropagation();
        console.log("right");
        _this.camera.lock = true;
        _this.currentX += 400;
        if (_this.currentX > _this.mainBg.width - s.width) {
          _this.currentX = _this.mainBg.width - s.width;
        }
        x = _this.camera.getOffsetPositionX(_this.currentX, _this.mainBg);
        if (x > _this.mainBg.width) {
          x = _this.mainBg.width;
        }
        return _this.camera.animate({
          x: x
        }, "normal", function() {
          return moveCallback();
        });
      };
      return this.menu.UI['move-left'].onclick = function(evt) {
        var x;
        evt.stopPropagation();
        console.log("left");
        _this.camera.lock = true;
        _this.currentX -= 400;
        if (_this.currentX < 0) {
          _this.currentX = 0;
        }
        x = _this.camera.getOffsetPositionX(_this.currentX, _this.mainBg);
        return _this.camera.animate({
          x: x
        }, "normal", function() {
          return moveCallback();
        });
      };
    };

    return Floor;

  })(Layer);

  FirstFloor = (function(_super) {
    __extends(FirstFloor, _super);

    function FirstFloor() {
      FirstFloor.__super__.constructor.apply(this, arguments);
      this.currentX = 400;
      this.camera.x = this.camera.getOffsetPositionX(this.currentX, this.mainBg);
    }

    FirstFloor.prototype.initLayers = function() {
      var float, main;
      main = new Layer(Res.imgs.homeDownMain);
      float = new Layer(Res.imgs.homeDownFloat);
      this.mainBg = main;
      main.z = 300;
      float.z = 0;
      float.fixToBottom();
      float.x = 1000;
      this.camera.render(main, float);
      this.camera.defaultReferenceZ = main.z;
      return this.layers = {
        main: main,
        float: float
      };
    };

    FirstFloor.prototype.show = function() {
      this.fadeIn("fast");
      return this.menu.show();
    };

    return FirstFloor;

  })(Floor);

  SecondFloor = (function(_super) {
    __extends(SecondFloor, _super);

    function SecondFloor() {
      _ref = SecondFloor.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    SecondFloor.prototype.initLayers = function() {
      var main;
      main = new Layer(Res.imgs.homeDown);
      this.mainBg = main;
      this.layers = {
        main: main
      };
      return this.camera.render(main);
    };

    SecondFloor.prototype.showWorkTable = function() {
      var worktable,
        _this = this;
      worktable = new Worktable(this.home);
      this.onshow = false;
      this.home.drawQueueAddAfter(worktable);
      return worktable.on("close", function() {
        _this.home.drawQueueRemove(worktable);
        _this.onshow = true;
        return _this.menu.show();
      });
    };

    return SecondFloor;

  })(Floor);

  window.Home = (function(_super) {
    __extends(Home, _super);

    function Home(game) {
      Home.__super__.constructor.call(this);
      this.game = game;
      this.firstFloor = new FirstFloor(this);
      this.secondFloor = new SecondFloor(this);
      this.drawQueueAdd(this.firstFloor, this.secondFloor);
      this.firstFloor.show();
    }

    Home.prototype.goUp = function() {};

    Home.prototype.goDown = function() {};

    Home.prototype.exit = function() {
      this.clearDrawQueue();
      return this.game.switchStage("worldMap");
    };

    return Home;

  })(Stage);

}).call(this);
