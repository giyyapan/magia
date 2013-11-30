// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Drawable = (function(_super) {
    __extends(Drawable, _super);

    function Drawable(x, y, width, height) {
      Drawable.__super__.constructor.call(this);
      this.x = x || 0;
      this.y = y || 0;
      this.z = null;
      this.secondCanvas = null;
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
      this.blendQueue = [];
      this.onshow = true;
      this.transform = {
        opacity: null,
        translateX: 0,
        translateY: 0,
        translateZ: 0,
        scaleX: 1,
        scaleY: 1,
        scale: null,
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
      _ref = Drawable.Animate.funcs;
      _results = [];
      for (name in _ref) {
        f = _ref[name];
        _results.push(this[name] = f);
      }
      return _results;
    };

    Drawable.prototype.blendWith = function(blendImg, method) {
      if (!blendImg instanceof BlendImg) {
        return console.error("invailid blendImg", blendImg);
      }
      if (!method) {
        return console.error("no method!");
      }
      if (!this.secondCanvas) {
        this.secondCanvas = $("#secondCanvas").get(0);
      }
      return this.blendQueue.push({
        blendImg: blendImg,
        method: method
      });
    };

    Drawable.prototype.onDraw = function(context, tickDelay) {
      var name, value, _ref;

      this._handleAnimate(tickDelay);
      if (!this.onshow) {
        return;
      }
      _ref = this.transform;
      for (name in _ref) {
        value = _ref[name];
        this.realValue[name] = value;
      }
      if (this.blendQueue.length > 0) {
        return this.onDrawBlend(context, tickDelay);
      } else {
        return this.onDrawNormal(context, tickDelay);
      }
    };

    Drawable.prototype.sortDrawQueue = function() {
      this.drawQueue.after.sort(function(a, b) {
        return (a.z || 0) - (b.z || 0);
      });
      return this.drawQueue.before.sort(function(a, b) {
        if (this.drawQueue.before) {
          return (a.z || 0) - (b.z || 0);
        }
      });
    };

    Drawable.prototype.onDrawBlend = function(context, tickDelay) {
      var b, item, realContext, tempContext, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;

      realContext = context;
      tempContext = this.secondCanvas.getContext("2d");
      tempContext.clearRect(0, 0, this.width, this.height);
      _ref = this.drawQueue.before;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        item.onDraw(tempContext, 0);
      }
      if (this.draw) {
        this.draw(tempContext);
      }
      _ref1 = this.drawQueue.after;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        item = _ref1[_j];
        item.onDraw(tempContext, 0);
      }
      this.currentImgData = tempContext.getImageData(0, 0, this.width, this.height);
      _ref2 = this.blendQueue;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        b = _ref2[_k];
        this.currentImgData = this._handleBlend(tempContext, this.currentImgData, b);
      }
      return this.onDrawNormal(realContext, tickDelay);
    };

    Drawable.prototype.onDrawNormal = function(context, tickDelay) {
      var item, _i, _j, _len, _len1, _ref, _ref1;

      context.save();
      this.emit("render", this);
      this._handleTransform(context);
      _ref = this.drawQueue.before;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        item.onDraw(context, tickDelay);
      }
      if (this.draw) {
        this.draw(context);
      }
      _ref1 = this.drawQueue.after;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        item = _ref1[_j];
        item.onDraw(context, tickDelay);
      }
      return context.restore();
    };

    Drawable.prototype._handleBlend = function(tempContext, currentImgData, blendQueueItem) {
      var blendData, blendFunc, blendImgDataPixars, blendImgIndex, currentImgDataPixars, currentImgIndex, p, pba, pbb, pbg, pbr, pca, pcb, pcg, pcr, x, y, _i, _j, _ref, _ref1;

      blendData = blendQueueItem.blendImg.getData(tempContext);
      switch (blendQueueItem.method) {
        case "overlay":
        case "linearLight":
          blendFunc = Drawable.BlendMethod[blendQueueItem.method];
          break;
        default:
          return console.error("invailid blend method " + blendQueueItem.method);
      }
      blendImgDataPixars = blendData.imgData.data;
      currentImgDataPixars = currentImgData.data;
      for (x = _i = 0, _ref = blendData.imgData.width; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        for (y = _j = 0, _ref1 = blendData.imgData.height; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
          blendImgIndex = (x + y * blendData.imgData.width) * 4;
          currentImgIndex = ((x + blendData.x) + (y + blendData.y) * currentImgData.width) * 4;
          pcr = currentImgDataPixars[currentImgIndex];
          pcg = currentImgDataPixars[currentImgIndex + 1];
          pcb = currentImgDataPixars[currentImgIndex + 2];
          pca = currentImgDataPixars[currentImgIndex + 3];
          pbr = blendImgDataPixars[blendImgIndex];
          pbg = blendImgDataPixars[blendImgIndex + 1];
          pbb = blendImgDataPixars[blendImgIndex + 2];
          pba = blendImgDataPixars[blendImgIndex + 3];
          if (pcr === void 0 || pbr === void 0) {
            continue;
          }
          p = blendFunc(pcr, pcg, pcb, pca, pbr, pbg, pbb, pba);
          currentImgDataPixars[currentImgIndex] = p.r;
          currentImgDataPixars[currentImgIndex + 1] = p.g;
          currentImgDataPixars[currentImgIndex + 2] = p.b;
          currentImgDataPixars[currentImgIndex + 3] = p.a;
        }
      }
      return currentImgData;
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
      r.scaleX = r.scale || r.scaleX || 1;
      r.scaleY = r.scale || r.scaleY || 1;
      context.scale(r.scaleX, r.scaleY);
      context.translate(x >> 0, y >> 0);
      if (r.rotate) {
        return context.rotate(r.rotate);
      }
    };

    Drawable.prototype.clearImg = function() {
      return this.imgData = null;
    };

    Drawable.prototype.drawColor = function(color) {
      this.clearImg();
      return this.fillColor = color;
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
      var i, img, s;

      s = Utils.getSize();
      if (-this.anchor.x >= s.width || -this.anchor.y >= s.height) {
        return;
      }
      if (this.imgData) {
        i = this.imgData;
        if (this.currentImgData) {
          context.putImageData(this.currentImgData, 0, 0, -this.anchor.x, -this.anchor.y, this.width, this.height);
          return this.currentImgData = null;
        } else {
          img = i.img;
          if (i.x) {
            return context.drawImage(img, i.x, i.y, i.width, i.height, -this.anchor.x, -this.anchor.y, this.width, this.height);
          } else {
            return context.drawImage(img, -this.anchor.x, -this.anchor.y, this.width, this.height);
          }
        }
      } else if (this.fillColor) {
        context.fillStyle = this.fillColor;
        return context.fillRect(-this.anchor.x, -this.anchor.y, this.width, this.height);
      }
    };

    Drawable.prototype.clearDrawQueue = function() {
      this.drawQueue.after = [];
      return this.drawQueue.before = [];
    };

    Drawable.prototype.drawQueueRemove = function(target) {
      var arr1, arr2, d, _i, _j, _len, _len1, _ref, _ref1;

      arr1 = [];
      _ref = this.drawQueue.after;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        d = _ref[_i];
        if (d !== target) {
          arr1.push(d);
        }
      }
      this.drawQueue.after = arr1;
      if (arr1.length !== this.drawQueue.after.length) {
        return;
      }
      if (!this.drawQueue.before) {
        return;
      }
      arr2 = [];
      _ref1 = this.drawQueue.before;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        d = _ref1[_j];
        if (d !== target) {
          arr2.push(d);
        }
      }
      return this.drawQueue.before = arr2;
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
      var a, arr, index, item, old, p, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1;

      if (this._animates.length === 0) {
        return;
      }
      _ref = this._animates;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        a = _ref[_i];
        a.sumDelay += tickDelay;
        p = a.easing(a.time, a.sumDelay, a.tickDelay);
        a.lastP = p;
        if (p > 0.99 || p < a.lastP) {
          p = 1;
          a.end = true;
        }
        a.func.call(this, p);
      }
      arr = [];
      old = this._animates;
      _ref1 = this._animates;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        a = _ref1[_j];
        if (!a.end) {
          arr.push(a);
        }
      }
      this._animates = arr;
      for (_k = 0, _len2 = old.length; _k < _len2; _k++) {
        a = old[_k];
        if (a.end) {
          if (a.callback) {
            a.callback();
          }
        }
      }
      for (index = _l = 0, _len3 = old.length; _l < _len3; index = ++_l) {
        item = old[index];
        old[index] = null;
      }
      return true;
    };

    Drawable.prototype.setCallback = function(time, callback) {
      if (!callback) {
        return console.error("need a callback func");
      }
      return this.animate((function() {}), time, "linear", callback);
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
            time = GameConfig.speedValue.fast;
            break;
          case "normal":
            time = GameConfig.speedValue.normal;
            break;
          case "slow":
            time = GameConfig.speedValue.slow;
        }
      }
      if (typeof easing === "string") {
        easing = Drawable.Animate.easing[easing];
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
      var arr, d, dataObj, f, n, name, ref, targetValue, _i, _len;

      dataObj = {};
      for (name in obj) {
        targetValue = obj[name];
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
        if (typeof targetValue === "string") {
          if (targetValue.indexOf("+=") > -1) {
            d = parseFloat(targetValue.replace("+=", ""));
          }
          if (targetValue.indexOf("-=") > -1) {
            d = -parseFloat(targetValue.replace("-=", ""));
          }
        } else {
          d = targetValue - ref;
        }
        if (isNaN(d)) {
          console.error("invailid value:" + d + " for " + name);
        }
        dataObj[name] = {
          origin: ref,
          delta: d
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

  Drawable.BlendMethod = {
    linearLight: function(r1, g1, b1, a1, r2, g2, b2, a2) {
      var a, b, g, p, r;

      a = a2 / 255;
      r = Math.min(255, Math.max(0, (r2 + 2 * r1) - 1)) >> 0;
      g = Math.min(255, Math.max(0, (g2 + 2 * g1) - 1)) >> 0;
      b = Math.min(255, Math.max(0, (b2 + 2 * b1) - 1)) >> 0;
      return p = {
        r: ((1 - a) * r1 + a * r) >> 0,
        g: ((1 - a) * g1 + a * g) >> 0,
        b: ((1 - a) * b1 + a * b) >> 0,
        a: a1
      };
    }
  };

  Drawable.Animate = {
    easing: {
      swing: function(time, sumDelay) {
        var p;

        return p = sumDelay / time;
      },
      linear: function(time, sumDelay, tickDelay) {
        var p;

        p = sumDelay / time;
        return -Math.cos(p * Math.PI) / 2 + 0.5;
      },
      expoIn: function(d, t) {
        return Math.pow(2, 10 * (t / d - 1));
      },
      expoOut: function(d, t) {
        return -Math.pow(2, -10 * t / d) + 1;
      },
      expoInOut: function(d, t) {
        t = t / (d / 2);
        if (t < 1) {
          return Math.pow(2, 10 * (t - 1)) / 2;
        } else {
          t = t - 1;
        }
        return (-Math.pow(2, -10 * t) + 2) / 2;
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
      console.log(img, this);
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

  window.BlendImg = (function(_super) {
    __extends(BlendImg, _super);

    function BlendImg(source, x, y, width, height) {
      BlendImg.__super__.constructor.call(this, x, y, width, height);
      if (typeof source === "string") {
        this.type = "color";
      } else {
        this.type = "img";
      }
      this.source = source;
    }

    BlendImg.prototype.getData = function(context) {
      context.clearRect(0, 0, this.width, this.height);
      if (this.type === "color") {
        context.fillStyle = this.source;
        context.fillRect(0, 0, this.width, this.height);
      } else {
        context.drawImage(this.source, 0, 0, width, data);
      }
      return {
        x: this.x,
        y: this.y,
        imgData: context.getImageData(0, 0, this.width, this.height)
      };
    };

    return BlendImg;

  })(Drawable);

}).call(this);
