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
      this.width = width || null;
      this.height = height || null;
      this.fixedYCoordinates = false;
      this.anchor = {
        x: parseInt(this.width / 2),
        y: parseInt(this.height / 2)
      };
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
      if (x.x) {
        y = x.y;
        x = x.x;
      }
      return this.anchor = {
        x: parseInt(x),
        y: parseInt(y)
      };
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
      if (r.scaleX < 0) {
        x = -x;
      }
      if (r.scaleY < 0) {
        y = -y;
      }
      if (r.scaleX === null) {
        r.scaleX = r.scale || 1;
      }
      if (r.scaleY === null) {
        r.scaleY = r.scale || 1;
      }
      context.scale(r.scaleX, r.scaleY);
      context.translate(parseInt(x), parseInt(y));
      if (r.rotate) {
        return context.rotate(r.rotate);
      }
    };

    Drawable.prototype.setImg = function(img, resX, resY, resWidth, resHeight) {
      if (!(img instanceof Image)) {
        console.error("need a img to set!", this);
        return;
      }
      this.imgData = {
        img: img,
        x: resX || null,
        y: resY || null,
        width: resWidth || null,
        height: resHeight || null
      };
      if (!this.width) {
        this.width = img.width;
      }
      if (!this.height) {
        this.height = img.height;
      }
      return this;
    };

    Drawable.prototype.draw = function(context) {
      var i, s;
      if (!this.onshow) {
        return;
      }
      s = Utils.getSize();
      if (-this.anchor.x >= s.width || -this.anchor.y >= s.height) {
        return;
      }
      if (this.imgData) {
        i = this.imgData;
        if (i.x) {
          return context.drawImage(i.img, i.x, i.y, i.width, i.height, -this.anchor.x, -this.anchor.y, this.width, this.height);
        } else {
          return context.drawImage(i.img, -this.anchor.x, -this.anchor.y, this.width, this.height);
        }
      } else if (GameConfig.debug === 2) {
        context.fillStyle = "black";
        context.fillRect(-50, -50, 100, 100);
        context.fillStyle = "darkred";
        return context.fillText("" + (parseInt(this.anchor.x)) + "," + (parseInt(this.anchor.y)), 0, 100);
      }
    };

    Drawable.prototype.clearDrawQueue = function() {
      this.drawQueue.after = [];
      return this.drawQueue.before = [];
    };

    Drawable.prototype.drawQueueRemove = function(drawable) {
      if (Utils.removeItem(drawable, this.drawQueue.after)) {
        return;
      }
      return Utils.removeItem(drawable, this.drawQueue.before);
    };

    Drawable.prototype.drawQueueAdd = function() {
      return this.drawQueueAddAfter.apply(this, arguments);
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
        if (p > 0.98) {
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
      if (typeof easing === "function" && typeof callback === "undefined") {
        callback = easing;
        easing = "swing";
      }
      if (!easing) {
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
      shake: function(time, callback) {
        var x, y;
        x = this.x;
        y = this.y;
        return this.animate((function(p) {
          if (p === 1) {
            return this.x = x;
          } else {
            return this.x = x + Math.sin(p * 10) * 10;
          }
        }), time, "swing", callback);
      },
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
      var s, z;
      s = Utils.getSize();
      Layer.__super__.constructor.call(this, 0, 0, s.width, s.height);
      z = 100;
      this.setAnchor(0, 0);
      if (img instanceof Image) {
        this.setImg(img);
      }
    }

    Layer.prototype.fixToBottom = function() {
      var s;
      s = Utils.getSize();
      this.y = s.height - this.height;
      return this.fixedYCoordinates = true;
    };

    Layer.prototype.setImg = function(img) {
      Layer.__super__.setImg.call(this, img);
      this.width = img.width;
      this.height = img.height;
      return this;
    };

    return Layer;

  })(Drawable);

  window.Stage = (function(_super) {
    __extends(Stage, _super);

    function Stage(game) {
      this.game = game;
      Stage.__super__.constructor.call(this);
      this.setAnchor(0, 0);
    }

    Stage.prototype.show = function(callback) {
      return this.fadeIn("normal", callback);
    };

    Stage.prototype.hide = function(callback) {
      return this.fadeOut("normal", callback);
    };

    Stage.prototype.draw = function() {};

    Stage.prototype.tick = function() {};

    return Stage;

  })(Drawable);

}).call(this);
