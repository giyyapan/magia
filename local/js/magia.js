// Generated by CoffeeScript 1.6.3
(function() {
  var Magia;

  Magia = (function() {
    function Magia() {
      var _this = this;
      $.get("http://baidu.com/", function(res) {
        return console.log(res);
      });
      this.player = new Player();
      this.size = null;
      this.res = null;
      this.canvas = new Suzaku.Widget("#gameCanvas");
      this.UILayer = new Suzaku.Widget("#UILayer");
      this.handleDisplaySize();
      this.km = new Suzaku.KeybordManager();
      this.db = null;
      window.Key = this.km.init();
      window.onresize = function() {
        return _this.handleDisplaySize();
      };
      this.loadResources(function() {
        _this.db = new Database();
        $("#loadingPage").slideUp("fast");
        _this.switchStage("worldMap");
        return _this.startGameLoop();
      });
    }

    Magia.prototype.switchStage = function(stage, data) {
      var s,
        _this = this;
      console.log("init stage:", stage);
      switch (stage) {
        case "start":
          s = new StartMenu(this, data);
          break;
        case "home":
          s = new Home(this, data);
          break;
        case "test":
          s = new TestStage(this, data);
          break;
        case "town":
          s = new Town(this, data);
          break;
        case "area":
          s = new Area(this, data);
          break;
        case "worldMap":
          s = new WorldMap(this, data);
      }
      if (this.currentStage) {
        return this.currentStage.hide(function() {
          _this.currentStage = s;
          return s.show();
        });
      } else {
        this.currentStage = s;
        return s.show();
      }
    };

    Magia.prototype.startGameLoop = function() {
      var self;
      self = this;
      return window.requestAnimationFrame(function() {
        self.tick();
        return self = null;
      });
    };

    Magia.prototype.tick = function() {
      var context, fps, now, self, tickDelay;
      self = this;
      this.lastTickTime = this.nowTickTime || 0;
      now = new Date().getTime();
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
        width: 1280,
        height: 720,
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
      console.log(targetHeight);
      console.log(targetWidth);
      w = Utils.sliceNumber(targetWidth / s.width, 3);
      h = Utils.sliceNumber(targetHeight / s.height, 3);
      s.scaleX = w;
      s.scaleY = h;
      J = $(".screen");
      console.log(s.screenWidth, targetWidth);
      console.log(parseInt((s.screenWidth - targetWidth) / 2));
      J.css("left", parseInt((s.screenWidth - targetWidth) / 2) + "px");
      Utils.setCSS3Attr(J, "transform", "scale(" + w + "," + h + ")");
      Utils.setCSS3Attr(J, "transform-origin", "" + 0 + "px 0");
      return console.log(this.canvas.dom);
    };

    Magia.prototype.loadResources = function(callback) {
      var loadingPage, name, rm, src, tpl, _i, _len, _ref, _ref1,
        _this = this;
      loadingPage = new Suzaku.Widget("#loadingPage");
      rm = new ResourceManager();
      rm.setPath("img", "img/");
      _ref = window.Imgs;
      for (name in _ref) {
        src = _ref[name];
        rm.useImg(name, src);
      }
      rm.setPath("template", "templates/");
      _ref1 = window.Templates;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        tpl = _ref1[_i];
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
        return callback();
      });
    };

    return Magia;

  })();

  window.onload = function() {
    var magia;
    return magia = new Magia();
  };

}).call(this);
