// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Widget = Suzaku.Widget;

  window.EventEmitter = Suzaku.EventEmitter;

  window.Clock = (function(_super) {
    __extends(Clock, _super);

    function Clock() {
      Clock.__super__.constructor.apply(this, arguments);
      this.setRate("normal");
      this.currentDelay = 0;
      this.currentDelay = 0;
    }

    Clock.prototype.setRate = function(value) {
      switch (value) {
        case "normal":
          value = 13;
          break;
        case "fast":
          value = 20;
          break;
        case "slow":
          value = 8;
          break;
        default:
          value = parseInt(value);
      }
      this.frameRate = value;
      return this.frameDelay = parseInt(1000 / this.frameRate);
    };

    Clock.prototype.tick = function(tickDelay) {
      var _results;
      this.currentDelay += tickDelay;
      _results = [];
      while (this.currentDelay > this.frameDelay) {
        this.currentDelay -= this.frameDelay;
        _results.push(this.emit("next"));
      }
      return _results;
    };

    return Clock;

  })(Suzaku.EventEmitter);

  window.Menu = (function(_super) {
    __extends(Menu, _super);

    function Menu(tpl) {
      Menu.__super__.constructor.call(this, tpl);
      this.isMenu = true;
      this.z = 0;
      this.UILayer = $(GameConfig.UILayerId);
    }

    Menu.prototype.init = function() {
      this.UILayer.hide();
      this.UILayer.html("");
      return this.appendTo(this.UILayer);
    };

    Menu.prototype.show = function(callback) {
      this.init();
      this.J.show();
      return this.UILayer.fadeIn("fast", callback);
    };

    Menu.prototype.hide = function(callback) {
      var _this = this;
      return this.UILayer.fadeOut("fast", function() {
        _this.J.hide();
        if (callback) {
          return callback();
        }
      });
    };

    Menu.prototype.onDraw = function() {
      return this.emit("render", this);
    };

    return Menu;

  })(Suzaku.Widget);

  window.PopupBox = (function(_super) {
    __extends(PopupBox, _super);

    function PopupBox(tpl) {
      var self;
      PopupBox.__super__.constructor.call(this, tpl || Res.tpls['popup-box']);
      this.box = this.UI.box;
      this.J.hide();
      this.box.J.hide();
      this.UILayer = $(GameConfig.UILayerId);
      self = this;
      if (this.UI['close-btn']) {
        this.UI['close-btn'].onclick = function() {
          return self.close();
        };
      }
      if (this.UI['accept-btn']) {
        this.UI['accept-btn'].onclick = function() {
          return self.accept();
        };
      }
    }

    PopupBox.prototype.show = function() {
      this.appendTo(this.UILayer);
      this.J.fadeIn("fast");
      return this.box.J.slideDown("fast");
    };

    PopupBox.prototype.close = function() {
      var self;
      self = this;
      this.J.fadeOut("fast");
      return this.box.J.slideUp("fast", function() {
        self.remove();
        return self = null;
      });
    };

    PopupBox.prototype.accept = function() {
      if (window.GameConfig.debug) {
        return console.log(this, "accept");
      }
    };

    return PopupBox;

  })(Suzaku.Widget);

}).call(this);
