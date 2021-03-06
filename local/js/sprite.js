// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Sprite = (function(_super) {
    __extends(Sprite, _super);

    function Sprite(x, y, spriteOriginData) {
      var name,
        _this = this;
      Sprite.__super__.constructor.call(this, x, y);
      this.spriteOriginData = spriteOriginData;
      this.dspName = spriteOriginData.name;
      this.animateClock = new Clock();
      this.animateClock.setRate("normal");
      this.animateClock.on("next", function() {
        return _this._nextFrame();
      });
      this.currentMove = null;
      this.currentFrame = 0;
      this.initSprite();
      this.width = this.spriteData.frames[0].frame.w;
      this.height = this.spriteData.frames[0].frame.h;
      if (this.movements.normal) {
        this.defaultMovement = "normal";
      } else {
        for (name in this.movements) {
          this.defaultMovement = name;
          break;
        }
      }
      this.useMovement(this.defaultMovement, true);
      this.currentFrame = (this.currentMove.startFrame - 1) + Math.round(Math.random() * this.currentMove.length);
    }

    Sprite.prototype.onDraw = function(context, tickDelay) {
      this.animateClock.tick(tickDelay);
      return Sprite.__super__.onDraw.call(this, context, tickDelay);
    };

    Sprite.prototype.initSprite = function() {
      var a1, arr, data, f, kfs, name, _i, _len, _ref, _ref1;
      this.spriteMap = this.spriteOriginData.sprite.map;
      this.spriteData = this.spriteOriginData.sprite.data;
      this.movements = {};
      _ref = this.spriteOriginData.movements;
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
        x: parseInt(this.spriteOriginData.anchor.split(",")[0]),
        y: parseInt(this.spriteOriginData.anchor.split(",")[1])
      };
      return this.setAnchor(this.defaultAnchor);
    };

    Sprite.prototype.useMovement = function(name, loopThisMove, callback) {
      var data;
      if (loopThisMove == null) {
        loopThisMove = false;
      }
      if (!this.movements[name]) {
        return console.error("no movment:" + name + " in ", this);
      }
      if (typeof loopThisMove === "function") {
        callback = loopThisMove;
        loopThisMove = false;
      }
      this.emit("startMove:" + name);
      if (this.currentMove) {
        this.emit("endMove:" + this.currentMove.name);
        if (name !== this.currentMove.name) {
          this.emit("changeMove", name);
        }
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
      this.currentFrame = -1;
      if (callback) {
        return this.once("endMove:" + name, callback);
      }
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
        this.useMovement(this.loopMovement);
        return this._nextFrame();
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
