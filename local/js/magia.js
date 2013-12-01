// Generated by CoffeeScript 1.6.3
(function() {
  var Magia,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Magia = (function(_super) {
    __extends(Magia, _super);

    function Magia() {
      var _this = this;
      Magia.__super__.constructor.call(this, null);
      this.size = null;
      this.res = null;
      this.canvas = new Suzaku.Widget("#gameCanvas");
      this.UILayer = new Suzaku.Widget("#UILayer");
      this.handleDisplaySize();
      this.km = new Suzaku.KeybordManager();
      this.savedStageStack = [];
      this.player = null;
      this.missionManager = null;
      this.storyManager = null;
      this.db = null;
      window.Key = this.km.init();
      window.onresize = function() {
        return _this.handleDisplaySize();
      };
      this.loadResources(function() {
        _this.db = new Database();
        _this.player = new Player(_this.db);
        _this.missionManager = new MissionManager(_this);
        _this.storyManager = new StoryManager(_this);
        $("#loadingPage").slideUp("slow");
        window.AudioManager.stop("startMenu");
        window.AudioManager.play("home");
        _this.switchStage("start");
        return _this.startGameLoop();
      });
    }

    Magia.prototype.switchStage = function(stage, data) {
      var s,
        _this = this;
      console.log("init stage:", stage);
      if (typeof stage.tick === "function") {
        s = stage;
        if (!stage.stageName) {
          console.warn("not stage name for this stage", stage);
        }
      } else {
        switch (stage) {
          case "start":
            s = new StartMenu(this, data);
            window.AudioManager.play("startMenu");
            break;
          case "home":
            s = new Home(this, data);
            window.AudioManager.play("home");
            break;
          case "test":
            s = new TestStage(this, data);
            break;
          case "area":
            window.AudioManager.play("home");
            s = new Area(this, data);
            break;
          case "shop":
            s = new Shop(this, data);
            break;
          case "guild":
            s = new Guild(this, data);
            break;
          case "story":
            window.AudioManager.play("home");
            s = new StoryStage(this, data);
            break;
          case "battle":
            window.AudioManager.play("battleBgm");
            s = new Battlefield(this, data);
            break;
          case "worldMap":
            s = new WorldMap(this, data);
            break;
          default:
            console.error("invailid stage:" + stage);
        }
        s.stageName = stage;
        s.switchStageData = data;
      }
      if (this.currentStage) {
        this.currentStage.hide(function() {
          _this.currentStage = s;
          return s.show();
        });
      } else {
        this.currentStage = s;
        s.show();
      }
      this.emit("switchStage", s);
      return s;
    };

    Magia.prototype.clearSavedStage = function() {
      this.savedStageStack = [];
      return true;
    };

    Magia.prototype.popSavedStage = function() {
      return this.savedStageStack.pop();
    };

    Magia.prototype.saveStage = function() {
      return this.savedStageStack.push(this.currentStage);
    };

    Magia.prototype.restoreStage = function() {
      if (this.savedStageStack.length === 0) {
        console.error("restore stage from empty stack!");
        return false;
      }
      this.switchStage(this.popSavedStage());
      return true;
    };

    Magia.prototype.startGameLoop = function() {
      var self;
      self = this;
      window.requestAnimationFrame(function() {
        self.tick();
        return self = null;
      });
      return true;
    };

    Magia.prototype.tick = function() {
      var context, fps, now, self, tickDelay;
      self = this;
      now = new Date().getTime();
      this.lastTickTime = this.nowTickTime || now - 5;
      tickDelay = now - this.lastTickTime;
      fps = 1000 / tickDelay;
      if (window.GameConfig.maxFPS && fps > window.GameConfig.maxFPS) {
        window.setTimeout((function() {
          self.tick();
          return self = null;
        }), 10);
        return;
      }
      this.nowTickTime = now;
      context = this.canvas.dom.getContext("2d");
      this.clearCanvas(context);
      if (this.currentStage) {
        this.currentStage.tick(tickDelay);
        this.currentStage.onDraw(context, tickDelay);
      }
      if (window.GameConfig.showFPS) {
        context.fillStyle = "white";
        context.font = "30px Arail";
        context.fillText("fps:" + (parseInt(fps)), 10, 30);
      }
      return window.requestAnimationFrame(function() {
        self.tick();
        return self = null;
      });
    };

    Magia.prototype.clearCanvas = function(context) {
      var s;
      s = Utils.getSize();
      return context.clearRect(0, 0, s.width, s.height);
    };

    Magia.prototype.go = function(step) {};

    Magia.prototype.handleDisplaySize = function() {
      var J, h, s, targetHeight, targetWidth, w;
      if (window.screen.lockOrientation) {
        window.screen.lockOrientation("landscape");
      }
      s = {
        screenWidth: window.innerWidth,
        screenHeight: window.innerHeight,
        width: GameConfig.screen.width,
        height: GameConfig.screen.height,
        scaleX: 1,
        scaleY: 1
      };
      Utils.getSize = function() {
        return s;
      };
      if ((s.screenWidth / s.screenHeight) < (s.width / s.height)) {
        targetWidth = s.screenWidth;
        targetHeight = targetWidth / s.width * s.height;
      } else {
        targetHeight = s.screenHeight;
        targetWidth = targetHeight / s.height * s.width;
      }
      w = Utils.sliceNumber(targetWidth / s.width, 3);
      h = Utils.sliceNumber(targetHeight / s.height, 3);
      s.scaleX = w;
      s.scaleY = h;
      J = $(".screen");
      J.css("left", parseInt((s.screenWidth - targetWidth) / 2) + "px");
      Utils.setCSS3Attr(J, "transform", "scale(" + w + "," + h + ")");
      return Utils.setCSS3Attr(J, "transform-origin", "" + 0 + "px 0");
    };

    Magia.prototype.loadResources = function(callback) {
      var loadingPage, name, rm, src, tpl, _i, _len, _ref, _ref1, _ref2,
        _this = this;
      loadingPage = new Suzaku.Widget("#loadingPage");
      rm = new ResourceManager();
      rm.setPath("img", "img/");
      _ref = window.Imgs;
      for (name in _ref) {
        src = _ref[name];
        rm.useImg(name, src);
      }
      rm.setPath("sprite", "img/sprites/");
      _ref1 = window.Sprites;
      for (name in _ref1) {
        src = _ref1[name];
        rm.useSprite(name, src);
      }
      rm.setPath("template", "templates/");
      _ref2 = window.Templates;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        tpl = _ref2[_i];
        rm.useTemplate(tpl);
      }
      rm.on("loadOne", function(total, loaded, type) {
        var percent;
        percent = loaded / total * 100;
        return loadingPage.UI.percent.innerText = "" + (parseInt(percent)) + "%";
      });
      return rm.start(function() {
        window.Res = rm.loaded;
        window.Res.tpls = window.Res.templates;
        console.log(Res);
        return callback();
      });
    };

    return Magia;

  })(EventEmitter);

  window.onload = function() {
    var magia;
    return magia = new Magia();
  };

}).call(this);
