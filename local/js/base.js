// Generated by CoffeeScript 1.6.3
(function() {
  var Animate,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Drawable = (function(_super) {
    __extends(Drawable, _super);

    function Drawable(x, y, width, height) {
      Drawable.__super__.constructor.call(this);
      this.x = x || 0;
      this.y = y || 0;
      this.z = null;
      this.offsetSize = true;
      this.imgData = null;
      this.width = width || 30;
      this.height = height || 30;
      this.anchorX = parseInt(this.width / 2);
      this.anchorY = parseInt(this.height / 2);
      this.renderData = null;
      this.onshow = true;
      this.transform = {
        opacity: 1,
        translateX: 0,
        translateY: 0,
        translateZ: 0,
        scaleX: 1,
        scaleY: 1,
        scale: 1,
        rotate: 0,
        martrix: null
      };
      this.drawQueue = {
        before: [],
        after: []
      };
      this.realValue = {};
      this._initAnimate();
    }

    Drawable.prototype.setAnchor = function(x, y) {
      this.anchorX = x;
      return this.anchorY = y;
    };

    Drawable.prototype._initAnimate = function() {
      var f, name, _ref, _results;
      this._animates = [];
      _ref = Animate.funcs;
      _results = [];
      for (name in _ref) {
        f = _ref[name];
        _results.push(this[name] = f);
      }
      return _results;
    };

    Drawable.prototype.onDraw = function(context, tickDelay) {
      var item, name, value, _i, _j, _len, _len1, _ref, _ref1, _ref2;
      this._handleAnimate(tickDelay);
      _ref = this.transform;
      for (name in _ref) {
        value = _ref[name];
        if (value !== null) {
          this.realValue[name] = value;
        }
      }
      context.save();
      this.emit("render", this);
      this._handleTransform(context);
      _ref1 = this.drawQueue.before;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        item = _ref1[_i];
        item.onDraw(context, tickDelay);
      }
      if (this.draw) {
        this.draw(context);
      }
      _ref2 = this.drawQueue.after;
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        item = _ref2[_j];
        item.onDraw(context, tickDelay);
      }
      return context.restore();
    };

    Drawable.prototype._handleTransform = function(context) {
      var r, x, y;
      r = this.realValue;
      x = r.translateX + this.x;
      y = r.translateY + this.y;
      if (r.opacity !== null) {
        context.globalAlpha = r.opacity;
      }
      r.scaleX = r.scaleX || r.scale || 1;
      r.scaleY = r.scaleY || r.scale || 1;
      context.scale(r.scaleX, r.scaleY);
      context.translate(parseInt(x), parseInt(y));
      if (r.rotate) {
        return context.rotate(r.rotate);
      }
    };

    Drawable.prototype.setImg = function(img, resX, resY, resWidth, resHeight) {
      return this.imgData = {
        img: img,
        x: resX,
        y: resY,
        width: resWidth,
        height: resHeight
      };
    };

    Drawable.prototype.draw = function(context) {
      var i, s;
      if (!this.onshow) {
        return;
      }
      s = Utils.getSize();
      if (-this.anchorX >= s.width || -this.anchorY >= s.height) {
        return;
      }
      if (this.imgData) {
        i = this.imgData;
        if (i.x) {
          context.drawImage(i.img, i.x, i.y, i.width, i.height, -this.anchorX, -this.anchorY, this.width, this.height);
        } else {
          context.drawImage(i.img, -this.anchorX, -this.anchorY, this.width, this.height);
        }
        context.fillStyle = "black";
        context.fillRect(-50, -50, 100, 100);
        context.fillStyle = "darkred";
        return context.fillText("" + (parseInt(this.anchorX)) + "," + (parseInt(this.anchorY)), 0, 100);
      } else if (GameConfig.debug === 2) {
        context.fillStyle = "rgba(20,20,20,0.2)";
        return context.fillRect(-this.anchorX, -this.anchorY, this.width, this.height);
      }
    };

    Drawable.prototype.clearDrawQueue = function() {
      this.drawBefore = [];
      return this.drawAfter = [];
    };

    Drawable.prototype.drawQueueRemove = function(drawable) {
      if (Utils.removeItem(drawable, this.drawQueue.after)) {
        return;
      }
      return Utils.removeItem(drawable, this.drawQueue.before);
    };

    Drawable.prototype.drawQueueAddAfter = function() {
      var d, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        d = arguments[_i];
        if (!d.onDraw) {
          console.error("" + d + " is not drawable");
        }
        _results.push(this.drawQueue.after.push(d));
      }
      return _results;
    };

    Drawable.prototype.drawQueueAddBefore = function() {
      var d, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        d = arguments[_i];
        if (!d.onDraw) {
          console.error("" + d + " is not drawable");
        }
        _results.push(this.drawQueue.before.push(d));
      }
      return _results;
    };

    Drawable.prototype._handleAnimate = function(tickDelay) {
      var a, arr, item, p, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      _ref = this._animates;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a = _ref[_i];
        a.sumDelay += tickDelay;
        p = a.easing(a.time, a.sumDelay, a.tickDelay);
        if (p > 0.99) {
          p = 1;
          a.end = true;
        }
        a.func.call(this, p);
      }
      arr = [];
      _ref1 = this._animates;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        a = _ref1[_j];
        if (a.end) {
          if (a.callback) {
            a.callback();
          }
        } else {
          arr.push(a);
        }
      }
      _ref2 = this._animates;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        item = _ref2[_k];
        item = null;
      }
      return this._animates = arr;
    };

    Drawable.prototype.animate = function(func, time, easing, callback) {
      var obj;
      if (time == null) {
        time = "normal";
      }
      if (easing == null) {
        easing = "swing";
      }
      if (!func) {
        return console.error("no func");
      }
      if (typeof func === "object") {
        obj = func;
        func = this._generateAnimateFunc(obj);
      }
      if (typeof time === "string") {
        switch (time) {
          case "fast":
            time = 200;
            break;
          case "normal":
            time = 350;
            break;
          case "slow":
            time = 600;
        }
      }
      if (typeof easing === "string") {
        easing = Animate.easing[easing];
      }
      return this._animates.push({
        func: func,
        time: time,
        easing: easing,
        end: false,
        callback: callback,
        sumDelay: 0
      });
    };

    Drawable.prototype._generateAnimateFunc = function(obj) {
      var arr, dataObj, f, n, name, ref, targetValue, _i, _len;
      dataObj = {};
      for (name in obj) {
        targetValue = obj[name];
        if (isNaN(targetValue)) {
          if (GameConfig.debug) {
            console.error("invailid value:" + targetValue);
          }
        }
        arr = name.split(".");
        ref = this;
        for (_i = 0, _len = arr.length; _i < _len; _i++) {
          n = arr[_i];
          ref = ref[n];
        }
        if (isNaN(ref)) {
          if (GameConfig.debug) {
            console.error("invailid key:" + name + "," + n);
          }
        }
        dataObj[name] = {
          origin: ref,
          delta: targetValue - ref
        };
      }
      f = function(p) {
        var data, delta, index, _j, _len1, _results;
        _results = [];
        for (name in dataObj) {
          delta = dataObj[name];
          arr = name.split(".");
          ref = this;
          for (index = _j = 0, _len1 = arr.length; _j < _len1; index = ++_j) {
            n = arr[index];
            if (index < (arr.length - 1)) {
              ref = ref[n];
            }
          }
          n = arr.pop();
          data = dataObj[name];
          _results.push(ref[n] = data.origin + data.delta * p);
        }
        return _results;
      };
      return f;
    };

    return Drawable;

  })(Suzaku.EventEmitter);

  Animate = {
    easing: {
      swing: function(time, sumDelay) {
        var p;
        return p = sumDelay / time;
      },
      linear: function(time, sumDelay, tickDelay) {
        var p;
        p = sumDelay / time;
        return -Math.cos(p * Math.PI) / 2 + 0.5;
      }
    },
    funcs: {
      fadeIn: function(time, callback) {
        return this.animate((function(p) {
          return this.transform.opacity = p;
        }), time, "linear", callback);
      },
      fadeOut: function(time, callback) {
        return this.animate((function(p) {
          return this.transform.opacity = 1 - p;
        }), time, "linear", callback);
      }
    }
  };

  window.Layer = (function(_super) {
    __extends(Layer, _super);

    function Layer(img) {
      var s;
      s = Utils.getSize();
      Layer.__super__.constructor.call(this, 0, 0, s.width, s.height);
      this.setAnchor(0, 0);
      if (img instanceof Image) {
        this.setImg(img);
      }
    }

    return Layer;

  })(Drawable);

  window.Camera = (function(_super) {
    __extends(Camera, _super);

    function Camera(x, y) {
      var s;
      s = Utils.getSize();
      x = x || 0;
      y = y || 0;
      Camera.__super__.constructor.call(this, x, y, s.width, s.height);
      this.scale = 0;
      this.defaultX = this.x;
      this.defaultY = this.y;
      this.lens = this.defaultLens = 1;
      this.degree = 30;
    }

    Camera.prototype.lookAt = function(target, time) {
      this.moveTo(target.x, target.y, time);
      return this.lensTo(this.width / target.width * 1.1, time);
    };

    Camera.prototype.lensTo = function(l, time) {
      var dl,
        _this = this;
      dl = l - this.lens;
      return this.animate((function(p) {
        return _this.lens = dl * p;
      }), time, "swing");
    };

    Camera.prototype.moveTo = function(x, y, time) {
      var dx, dy,
        _this = this;
      dx = x - this.x;
      dy = y - this.y;
      return this.animate((function(p) {
        _this.x = dx * p;
        return _this.y = dy * p;
      }), time, "swing");
    };

    Camera.prototype.reset = function() {
      this.x = this.defaultX;
      this.y = this.defaultY;
      return this.lens = this.defaultLens;
    };

    Camera.prototype.onDraw = function(context, tickDelay) {
      return this._handleAnimate(tickDelay);
    };

    Camera.prototype.render = function() {
      var d, self, size, _i, _len, _results;
      self = this;
      size = Utils.getSize();
      _results = [];
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        d = arguments[_i];
        if (d.onDraw) {
          if (d.isMenu) {
            d.on("render", function() {
              return self._renderMenu(this, size);
            });
          } else {
            d.on("render", function() {
              return self._render(this, size);
            });
          }
        }
        if (!d.onDraw && GameConfig.debug) {
          _results.push(console.error("" + d + " is not drawable or Menu"));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Camera.prototype._render = function(d, s) {
      var r, rd, sX, sY;
      this.degree = 45;
      if (!d.renderData) {
        d.renderData = {
          z: d.z - 1
        };
      }
      rd = d.renderData;
      if (rd.z !== (d.z + d.realValue.translateZ)) {
        rd.z = d.z + d.realValue.translateZ;
        rd.scaleX = (s.width + d.z * Math.tan(this.degree)) / s.width;
        rd.scaleY = (s.height + d.z * Math.tan(this.degree)) / s.height;
      }
      sX = rd.scaleX * this.lens;
      sY = rd.scaleY * this.lens;
      r = d.realValue;
      r.rotate = r.rotate - this.rotate;
      r.translateX = r.translateX - (this.x / sX);
      r.translateY = r.translateY - (this.y / sY);
      if (d.offsetSize) {
        r.scaleX *= this.lens;
        return r.scaleY *= this.lens;
      } else {
        r.scaleX *= sX;
        return r.scaleY *= sY;
      }
    };

    Camera.prototype._renderMenu = function(m, s) {
      var rd, sX, sY, value, x, y;
      if (!m.renderData) {
        m.renderData = {
          z: m.z - 1
        };
      }
      rd = m.renderData;
      if (rd.z !== m.z) {
        rd.z = m.z;
        rd.scaleX = (s.width + m.z * Math.tan(this.degree)) / s.width;
        rd.scaleY = (s.height + m.z * Math.tan(this.degree)) / s.height;
      }
      sX = rd.scaleX * this.lens;
      sY = rd.scaleY * this.lens;
      x = -(this.x / sX);
      y = -(this.y / sY);
      Utils.setCSS3Attr(m.J, "transform-origin", "" + this.x + "px " + this.y + "px");
      value = "translate(" + x + "px," + y + "px) ";
      value += "rotate(" + this.transform.rotate + "deg) ";
      if (!m.offsetSize) {
        value += "scale(" + (rd.scaleX * this.lens) + "," + (rd.scaleY * this.lens) + ") ";
      }
      return Utils.setCSS3Attr(m.J, "transform", value);
    };

    return Camera;

  })(Drawable);

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

  window.Stage = (function(_super) {
    __extends(Stage, _super);

    function Stage(game) {
      this.game = game;
      Stage.__super__.constructor.call(this);
      this.anchorX = 0;
      this.anchorY = 0;
    }

    Stage.prototype.show = function(callback) {
      return this.fadeIn("fast", callback);
    };

    Stage.prototype.hide = function(callback) {
      return this.fadeOut("fast", callback);
    };

    Stage.prototype.draw = function() {};

    Stage.prototype.tick = function() {};

    return Stage;

  })(Drawable);

  window.PopupBox = (function(_super) {
    __extends(PopupBox, _super);

    function PopupBox(tpl) {
      var self;
      PopupBox.__super__.constructor.call(this, tpl || Res.tpls['popup-box']);
      this.box = this.UI.box;
      this.J.hide();
      this.box.J.hide();
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
      this.appendTo($("#UILayer"));
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
