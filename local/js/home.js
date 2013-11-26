// Generated by CoffeeScript 1.6.2
(function() {
  var FirstFloor, Floor, HomeMenu, SecondFloor, SubMenu,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  SubMenu = (function(_super) {
    __extends(SubMenu, _super);

    function SubMenu(tpl, menu) {
      var _this = this;

      SubMenu.__super__.constructor.call(this, tpl);
      this.menu = menu;
      this.dom.onclick = function() {
        _this.menu.showFunctionBtns();
        return _this.hide();
      };
    }

    SubMenu.prototype.setTitle = function(title) {
      return this.UI.title.J.text(title);
    };

    SubMenu.prototype.hide = function() {
      this.J.fadeOut("fast");
      return this.emit("hide");
    };

    SubMenu.prototype.show = function() {
      this.J.fadeIn("fast");
      return this.emit("show");
    };

    SubMenu.prototype.addBtn = function(name, btnCode) {
      var btn,
        _this = this;

      btn = new Widget(this.UI['sub-btn-tpl'].innerHTML);
      btn.UI.name.J.text(name);
      btn.appendTo(this.UI['sub-btn-box']);
      return btn.dom.onclick = function(evt) {
        var data;

        evt.stopPropagation();
        data = {
          autohide: true,
          showFunctionBtns: true
        };
        _this.menu.emit("activeSubMenu", btnCode, data);
        if (data.autohide) {
          _this.hide();
        }
        if (data.showFunctionBtns) {
          return _this.menu.showFunctionBtns();
        }
      };
    };

    return SubMenu;

  })(Widget);

  HomeMenu = (function(_super) {
    __extends(HomeMenu, _super);

    function HomeMenu(floor) {
      HomeMenu.__super__.constructor.call(this, Res.tpls['home-menu']);
      this.floor = floor;
      this.functionBtns = [];
      this.subMenu = new SubMenu(this.UI['sub-menu-layer'], this);
    }

    HomeMenu.prototype.showFunctionBtns = function() {
      var btn, _i, _len, _ref, _results;

      _ref = this.functionBtns;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        btn = _ref[_i];
        btn.J.removeClass("animate-pophide");
        _results.push(btn.css3Animate("animate-popup"));
      }
      return _results;
    };

    HomeMenu.prototype.hideFunctionBtns = function() {
      var btn, _i, _len, _ref, _results;

      _ref = this.functionBtns;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        btn = _ref[_i];
        _results.push(btn.J.addClass("animate-pophide"));
      }
      return _results;
    };

    HomeMenu.prototype.addFunctionBtn = function(name, x, y, callback) {
      var btn;

      btn = new Widget(this.UI['function-btn-tpl'].innerHTML);
      this.functionBtns.push(btn);
      btn.appendTo(this.UI['function-btn-box']);
      btn.name = name;
      btn.J.css({
        left: "" + x + "px",
        top: "" + y + "px"
      });
      return btn.dom.onclick = function() {
        if (callback) {
          return callback();
        }
      };
    };

    HomeMenu.prototype.showSubMenu = function(title) {
      var index, name, _i, _len;

      this.hideFunctionBtns();
      this.off("activeSubMenu");
      this.subMenu.UI['sub-btn-box'].J.html("");
      this.subMenu.setTitle(title);
      for (index = _i = 0, _len = arguments.length; _i < _len; index = ++_i) {
        name = arguments[index];
        if (index > 0) {
          this.subMenu.addBtn(name, index);
        }
      }
      return this.subMenu.show();
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
      this.initMenu();
      this.initLayers();
      this.initFunctionBtns();
      this.init();
    }

    Floor.prototype.init = function() {
      this.currentX = 0;
      this.camera.reset();
      this.menu.show();
      return this.menu.showFunctionBtns();
    };

    Floor.prototype.initFunctionBtns = function() {
      return this.camera.render(this.menu.UI['function-btn-box']);
    };

    Floor.prototype.initLayers = function() {};

    Floor.prototype.initMenu = function() {
      var moveCallback, s,
        _this = this;

      s = Utils.getSize();
      this.menu = new HomeMenu(Res.tpls['home-menu']);
      moveCallback = function() {
        var x;

        x = _this.currentX;
        delete _this.camera.lock;
        if (x === 0) {
          _this.menu.UI['move-left'].J.removeClass("animate-popup").addClass("animate-pophide");
        } else {
          _this.menu.UI['move-left'].J.removeClass("animate-pophide").addClass("animate-popup");
        }
        if (x === (_this.mainBg.width - s.width)) {
          return _this.menu.UI['move-right'].J.removeClass("animate-popup").addClass("animate-pophide");
        } else {
          return _this.menu.UI['move-right'].J.removeClass("animate-pophide").addClass("animate-popup");
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
        }, 300, "swing", function() {
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
        }, 300, "swing", function() {
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

    FirstFloor.prototype.initFunctionBtns = function() {
      var _this = this;

      FirstFloor.__super__.initFunctionBtns.apply(this, arguments);
      this.menu.addFunctionBtn("上楼", 173, 20, function() {
        _this.menu.showSubMenu("楼梯", "上楼");
        return _this.menu.on("activeSubMenu", function(buttonCode, data) {
          data.showFunctionBtns = false;
          return _this.home.goUp();
        });
      });
      this.menu.addFunctionBtn("玄关", 580, 600, function() {
        _this.menu.showSubMenu("玄关", "出门");
        return _this.menu.on("activeSubMenu", function(buttonCode) {
          return _this.home.exit();
        });
      });
      this.menu.addFunctionBtn("卧室", 1154, 98, function() {
        _this.menu.showSubMenu("卧室", "换衣服", "睡觉");
        return _this.menu.on("activeSubMenu", function(buttonCode) {
          switch (buttonCode) {
            case 1:
              return console.log("换衣服");
            case 2:
              return alert("zzz");
          }
        });
      });
      return this.menu.addFunctionBtn("猫", 1548, 425, function() {
        _this.menu.showSubMenu("猫", "调戏", "对话");
        return _this.menu.on("activeSubMenu", function(buttonCode) {
          switch (buttonCode) {
            case 1:
              return alert("调戏你妹啊！");
            case 2:
              return alert("喵喵喵");
          }
        });
      });
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
      SecondFloor.__super__.constructor.apply(this, arguments);
      this.onshow = false;
    }

    SecondFloor.prototype.initLayers = function() {
      var main;

      main = new Layer(Res.imgs.homeUp);
      this.mainBg = main;
      this.layers = {
        main: main
      };
      return this.camera.render(main);
    };

    SecondFloor.prototype.initFunctionBtns = function() {
      var _this = this;

      SecondFloor.__super__.initFunctionBtns.apply(this, arguments);
      this.menu.addFunctionBtn("工作台", 180, 140, function() {
        _this.menu.showSubMenu("工作台", "素材加工");
        return _this.menu.on("activeSubMenu", function(buttonCode) {
          switch (buttonCode) {
            case 1:
              return _this.showWorkTable();
          }
        });
      });
      return this.menu.addFunctionBtn("下楼", 706, 120, function() {
        _this.menu.showSubMenu("楼梯", "下楼");
        return _this.menu.on("activeSubMenu", function(buttonCode, data) {
          data.showFunctionBtns = false;
          return _this.home.goDown();
        });
      });
    };

    SecondFloor.prototype.showWorkTable = function() {
      var worktable,
        _this = this;

      worktable = new Worktable(this.home);
      this.mainBg.onshow = false;
      this.drawQueueAdd(worktable);
      return worktable.on("close", function() {
        _this.drawQueueRemove(worktable);
        console.log("close");
        _this.mainBg.onshow = true;
        return _this.init();
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

    Home.prototype.goDown = function() {
      var _this = this;

      return this.secondFloor.camera.animate({
        x: 200,
        y: -50,
        scale: 1.4
      }, 200, function() {
        return _this.secondFloor.camera.animate({
          x: "-=50",
          y: "+=50"
        }, 330, "expoOut", function() {
          _this.secondFloor.fadeOut(350);
          return _this.secondFloor.camera.animate({
            x: "-=50",
            y: "+=50"
          }, 330, "expoOut", function() {
            return _this.secondFloor.camera.animate({
              x: "-=50",
              y: "+=50"
            }, 330, "expoOut", function() {
              _this.secondFloor.onshow = false;
              _this.firstFloor.onshow = true;
              _this.firstFloor.y = +300;
              _this.firstFloor.transform.opacity = 0;
              _this.firstFloor.animate({
                "transform.opacity": 1,
                y: 0
              }, 500, "expoOut");
              return _this.firstFloor.init();
            });
          });
        });
      });
    };

    Home.prototype.goUp = function() {
      var _this = this;

      return this.firstFloor.camera.animate({
        x: -250,
        y: -50,
        scale: 1.4
      }, 200, function() {
        return _this.firstFloor.camera.animate({
          x: "+=50",
          y: "-=50"
        }, 330, "expoOut", function() {
          _this.firstFloor.fadeOut(350);
          return _this.firstFloor.camera.animate({
            x: "+=50",
            y: "-=50"
          }, 330, "expoOut", function() {
            return _this.firstFloor.camera.animate({
              x: "+=50",
              y: "-=50"
            }, 330, "expoOut", function() {
              _this.firstFloor.onshow = false;
              _this.secondFloor.onshow = true;
              _this.secondFloor.y = -300;
              _this.secondFloor.transform.opacity = 0;
              _this.secondFloor.animate({
                "transform.opacity": 1,
                y: 0
              }, 500, "expoOut");
              return _this.secondFloor.init();
            });
          });
        });
      });
    };

    Home.prototype.exit = function() {
      var _this = this;

      this.firstFloor.fadeOut("slow");
      return this.fadeOut("slow", function() {
        _this.clearDrawQueue();
        return _this.game.switchStage("worldMap");
      });
    };

    return Home;

  })(Stage);

}).call(this);
