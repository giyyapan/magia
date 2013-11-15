// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Sprite = (function(_super) {
    __extends(Sprite, _super);

    function Sprite(x, y, originData) {
      var _this = this;
      Sprite.__super__.constructor.call(this, x, y);
      this.originData = originData;
      this.dspName = originData.name;
      this.animateClock = new Clock();
      this.animateClock.setRate("normal");
      this.animateClock.on("next", function() {
        return _this._nextFrame();
      });
      this.currentMove = null;
      this.currentFrame = 0;
      this.initSprite();
      this.defaultMovement = "normal";
      this.useMovement("normal", true);
      this.currentFrame = (this.currentMove.startFrame - 1) + Math.round(Math.random() * this.currentMove.length);
    }

    Sprite.prototype.onDraw = function(context, tickDelay) {
      this.animateClock.tick(tickDelay);
      return Sprite.__super__.onDraw.call(this, context, tickDelay);
    };

    Sprite.prototype.initSprite = function() {
      var a1, arr, data, f, kfs, name, _i, _len, _ref, _ref1;
      this.spriteMap = this.originData.sprite.map;
      this.spriteData = this.originData.sprite.data;
      this.movements = {};
      _ref = this.originData.movements;
      for (name in _ref) {
        data = _ref[name];
        a1 = data.split(":");
        arr = a1[0].split(",");
        this.movements[name] = {
          startFrame: parseInt(arr[0]),
          endFrame: parseInt(arr[1]),
          length: parseInt(arr[1]) - parseInt(arr[0]),
          keyFrames: null
        };
        if (a1[1]) {
          kfs = [];
          _ref1 = a1[1].split(",");
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            f = _ref1[_i];
            kfs.push(parseInt(f));
          }
          this.movements[name].keyFrames = kfs;
        }
      }
      this.defaultAnchor = {
        x: parseInt(this.originData.anchor.split(",")[0]),
        y: parseInt(this.originData.anchor.split(",")[1])
      };
      return this.setAnchor(this.defaultAnchor);
    };

    Sprite.prototype.useMovement = function(name, loopThisMove) {
      var data;
      if (loopThisMove == null) {
        loopThisMove = false;
      }
      if (!this.movements[name]) {
        return console.error("no movment:" + name + " in ", this);
      }
      if (this.currentMove && name !== this.currentMove.name) {
        this.emit("endMove:" + this.currentMove.name);
        this.emit("startMove:" + name);
      }
      if (loopThisMove) {
        this.loopMovement = name;
      }
      data = this.movements[name];
      this.currentMove = {
        name: name,
        startFrame: data.startFrame,
        endFrame: data.endFrame,
        length: data.length,
        keyFrames: data.keyFrames
      };
      return this.currentFrame = -1;
    };

    Sprite.prototype._nextFrame = function() {
      var ax, ay, data, f, frameData, index, realFrame, resHeight, resWidth, resX, resY, _i, _len, _ref;
      this.currentFrame += 1;
      if (this.currentMove.keyFrames) {
        _ref = this.currentMove.keyFrames;
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          f = _ref[index];
          if ((this.currentFrame + 1) === f) {
            this.emit("keyFrame", index, this.currentMove.keyFrames.length);
            break;
          }
        }
      }
      realFrame = this.currentMove.startFrame + this.currentFrame;
      if (realFrame > this.currentMove.endFrame) {
        return this.useMovement(this.loopMovement);
      } else {
        data = this.spriteData.frames[realFrame];
        if (!data) {
          console.error("movement frame out of range!", this, realFrame);
          return;
        }
        ax = this.defaultAnchor.x - data.spriteSourceSize.x;
        ay = this.defaultAnchor.y - data.spriteSourceSize.y;
        frameData = data.frame;
        resX = frameData.x;
        resY = frameData.y;
        resWidth = frameData.w;
        resHeight = frameData.h;
        this.width = frameData.w;
        this.height = frameData.h;
        this.setAnchor(ax, ay);
        return this.setImg(this.spriteMap, resX, resY, resWidth, resHeight);
      }
    };

    return Sprite;

  })(Drawable);

}).call(this);
