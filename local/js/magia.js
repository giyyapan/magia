(function() {
  var Magia;

  Magia = (function() {

    function Magia() {
      var _this = this;
      this.playerData = new PlayerData();
      this.size = null;
      this.canvas = new Suzaku.Widget("#gameCanvas");
      this.UILayer = new Suzaku.Widget("#UILayer");
      this.handleDisplaySize();
      window.onresize = function() {
        return _this.handleDisplaySize();
      };
      this.loadResources(function() {
        return _this.initScene("start");
      });
    }

    Magia.prototype.initScene = function(scene) {
      var s;
      console.log("init scene:", scene);
      switch (scene) {
        case "start":
          s = new StartScene(this);
          break;
        case "home":
          s = new HomeScene(this);
      }
      return s.show();
    };

    Magia.prototype.handleDisplaySize = function() {
      var J, h, s, targetHeight, targetWidth, w;
      s = {
        width: window.innerWidth,
        height: window.innerHeight,
        defaultWidth: 1280,
        defaultHeight: 720
      };
      this.screenSize = s;
      if ((s.width / s.height) < (s.defaultWidth / s.defaultHeight)) {
        targetWidth = s.width;
        targetHeight = targetWidth / s.defaultWidth * s.defaultHeight;
      } else {
        targetHeight = s.height;
        targetWidth = targetHeight / s.defaultHeight * s.defaultWidth;
      }
      console.log(targetHeight);
      console.log(targetWidth);
      w = Utils.sliceNumber(targetWidth / s.defaultWidth, 3);
      h = Utils.sliceNumber(targetHeight / s.defaultHeight, 3);
      J = $(".screen");
      console.log(s.width, targetWidth);
      console.log(parseInt((s.width - targetWidth) / 2));
      J.css("left", parseInt((s.width - targetWidth) / 2) + "px");
      Utils.setCSS3Attr(J, "transform", "scale(" + w + "," + h + ")");
      Utils.setCSS3Attr(J, "transform-origin", "" + 0 + "px 0");
      return console.log(this.canvas.dom);
    };

    Magia.prototype.loadResources = function(callback) {
      var loadingPage, name, rm, src, _ref,
        _this = this;
      loadingPage = new Suzaku.Widget("#loadingPage");
      rm = new ResourceManager();
      rm.setPath("img", "img/");
      _ref = window.Imgs;
      for (name in _ref) {
        src = _ref[name];
        rm.useImg(name, src);
      }
      rm.on("loadOne", function(total, loaded, type) {
        var percent;
        percent = loaded / total * 100;
        return loadingPage.UI.percent.innerText = "" + (parseInt(percent)) + "%";
      });
      return rm.start(callback);
    };

    return Magia;

  })();

  window.onload = function() {
    var magia;
    return magia = new Magia();
  };

}).call(this);
