// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Camera = (function(_super) {
    __extends(Camera, _super);

    function Camera(x, y) {
      var s;

      s = Utils.getSize();
      x = x || 0;
      y = y || 0;
      Camera.__super__.constructor.call(this, x, y, s.width, s.height);
      this.defaultScale = this.scale = 1;
      this.defaultX = this.x;
      this.defaultY = this.y;
      this.degree = 45;
      this.secondCanvas = $("#secondCanvas").get(0);
      this.defaultReferenceZ = 0;
      this.followData = null;
    }

    Camera.prototype.follow = function(target, z) {
      return this.followData = {
        target: target,
        z: z
      };
    };

    Camera.prototype.unfollow = function() {
      return this.followData = null;
    };

    Camera.prototype._handleFollow = function() {
      if (!this.followData) {
        return;
      }
      return this.setCenter(this.followData.target.x, this.followData.target.y, this.followData.z);
    };

    Camera.prototype.setCenter = function(x, y, z) {
      var s;

      s = Utils.getSize();
      if (!z) {
        z = this.defaultReferenceZ;
      }
      x = this.getOffsetPositionX(s.width / 2 - x, z);
      y = this.getOffsetPositionY(s.height / 2 - y, z);
      this.x = -x;
      return this.y = -y;
    };

    Camera.prototype.lookAtInsideBorder = function(target, border, scale, callback) {
      var z;

      return z = border.z || this.defaultReferenceZ;
    };

    Camera.prototype.lookAt = function(target, time, scale, z, callback) {
      var s, x, y;

      if (!z) {
        z = this.defaultReferenceZ;
      }
      s = Utils.getSize();
      x = this.getOffsetPositionX(s.width / 2 - target.x, z);
      y = this.getOffsetPositionY(s.height / 2 - target.y, z);
      this.moveTo(-x, -y, time, callback);
      return this.scaleTo(scale || s.width / target.width * 0.48, time, callback);
    };

    Camera.prototype.scaleTo = function(scale, time) {
      return this.animate({
        scale: scale
      }, time, "expoOut");
    };

    Camera.prototype.moveTo = function(x, y, time, callback) {
      if (x === null) {
        x = this.x;
      }
      if (y === null) {
        y = this.y;
      }
      return this.animate({
        x: x,
        y: y
      }, time, "expoOut", callback);
    };

    Camera.prototype.getOffsetPositionX = function(x, reference) {
      return x * this.getOffsetScaleX(reference);
    };

    Camera.prototype.getOffsetPositionY = function(y, reference) {
      return y * this.getOffsetScaleY(reference);
    };

    Camera.prototype.reset = function() {
      this.x = this.defaultX;
      this.y = this.defaultY;
      return this.scale = this.defaultScale;
    };

    Camera.prototype.onDraw = function(context, tickDelay) {
      this._handleFollow();
      this._handleAnimate(tickDelay);
      context.save();
      context.translate((this.width / 2) >> 0, (this.height / 2) >> 0);
      this.preRender(tickDelay);
      this.draw(context);
      return context.restore();
    };

    Camera.prototype.draw = function(context) {
      if (this.transform.opacity !== null) {
        context.globalAlpha = this.transform.opacity;
      }
      context.fillStyle = "black";
      return context.drawImage(this.secondCanvas, -(this.secondCanvas.width / 2 * this.scale) >> 0, -(this.secondCanvas.height / 2 * this.scale) >> 0, this.secondCanvas.width * this.scale, this.secondCanvas.height * this.scale);
    };

    Camera.prototype.preRender = function(tickDelay) {
      var context, h, item, s, w, _i, _len, _ref;

      s = Utils.getSize();
      w = s.width / this.scale >> 0;
      h = s.height / this.scale >> 0;
      this.secondCanvas.width = w;
      this.secondCanvas.height = h;
      context = this.secondCanvas.getContext("2d");
      context.clearRect(0, 0, w, h);
      context.save();
      context.translate((w - s.width) / 2, (h - s.height) / 2);
      _ref = this.drawQueue.after;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        item.onDraw(context, tickDelay);
      }
      return context.restore();
    };

    Camera.prototype.render = function() {
      var d, self, size, z, _i, _len;

      self = this;
      size = Utils.getSize();
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        d = arguments[_i];
        if (d instanceof HTMLElement || d instanceof $) {
          z = d.z || this.defaultReferenceZ;
          d = new Menu(d);
          d.z = z;
        }
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
          this.drawQueueAddAfter(d);
        }
        if (!d.onDraw && GameConfig.debug) {
          console.error("" + d + " is not drawable or Menu");
        }
      }
      return this.drawQueue.after.sort(function(a, b) {
        return b.z - a.z;
      });
    };

    Camera.prototype.getOffsetScaleX = function(targetZ, s) {
      if (typeof targetZ === "object") {
        targetZ = targetZ.z;
      }
      if (!s) {
        s = Utils.getSize();
      }
      return (s.width + targetZ * Math.tan(this.degree)) / s.width;
    };

    Camera.prototype.getOffsetScaleY = function(targetZ, s) {
      if (typeof targetZ === "object") {
        targetZ = targetZ.z;
      }
      if (!s) {
        s = Utils.getSize();
      }
      return (s.height + targetZ * Math.tan(this.degree)) / s.height;
    };

    Camera.prototype._render = function(d, s) {
      var r, rd, sX, sY;

      if (!d.renderData) {
        d.renderData = {
          z: d.z - 1
        };
      }
      rd = d.renderData;
      if (rd.z !== (d.z + d.realValue.translateZ)) {
        rd.z = d.z + d.realValue.translateZ;
        rd.scaleX = this.getOffsetScaleX(d, s);
        rd.scaleY = this.getOffsetScaleY(d, s);
      }
      sX = rd.scaleX;
      sY = rd.scaleY;
      r = d.realValue;
      r.rotate = r.rotate - this.rotate;
      r.translateX = r.translateX - (this.x / sX);
      if (!d.fixedYCoordinates) {
        r.translateY = r.translateY - (this.y / sY);
      }
      if (!d.offsetSize) {
        r.scaleX *= sX;
        return r.scaleY *= sY;
      }
    };

    Camera.prototype._renderMenu = function(m, s) {
      var originX, originY, rd, sX, sY, value, x, y;

      if (!m.z) {
        m.z = this.defaultReferenceZ;
      }
      if (!m.renderData) {
        m.renderData = {
          z: m.z - 1
        };
      }
      rd = m.renderData;
      if (rd.z !== m.z) {
        rd.z = m.z;
        rd.scaleX = this.getOffsetScaleX(m, s);
        rd.scaleY = this.getOffsetScaleY(m, s);
      }
      sX = rd.scaleX;
      sY = rd.scaleY;
      x = -(this.x / sX);
      y = -(this.y / sY);
      if (rd.x === x && rd.y === y && rd.rotate === this.transform.rotate && rd.scale === this.scale) {
        return;
      }
      rd.x = x;
      rd.y = y;
      rd.rotate = this.transform.rotate;
      rd.scale = this.scale;
      originX = (-x + s.width / 2) >> 0;
      originY = (-y + s.height / 2) >> 0;
      Utils.setCSS3Attr(m.J, "transform-origin", "" + originX + "px " + originY + "px");
      value = "translate(" + (x >> 0) + "px," + (y >> 0) + "px) ";
      value += "rotate(" + this.transform.rotate + "deg) ";
      value += "scale(" + this.scale + "," + this.scale + ") ";
      return Utils.setCSS3Attr(m.J, "transform", value);
    };

    return Camera;

  })(Drawable);

}).call(this);
