// Generated by CoffeeScript 1.6.3
(function() {
  var DialogCharacter,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  DialogCharacter = (function(_super) {
    __extends(DialogCharacter, _super);

    function DialogCharacter(tpl, name, data) {
      var img;
      DialogCharacter.__super__.constructor.call(this, tpl);
      this.name = name;
      img = Res.imgs[data.dialogPic];
      if (img) {
        this.UI.img.src = img.src;
      }
      this.position = null;
    }

    DialogCharacter.prototype.useEffect = function(name) {
      switch (name) {
        case "none":
          return this.UI.img.J.removeClass();
        case "shadow":
          return this.UI.img.J.addClass("shadow");
      }
    };

    DialogCharacter.prototype.getOut = function(type) {
      var _this = this;
      return this.J.fadeOut("fast", function() {
        return _this.remove();
      });
    };

    DialogCharacter.prototype.getIn = function(position) {
      this.position = position;
      if (!position) {
        if (this.name === "player") {
          position = "left";
        } else {
          position = "right";
        }
      }
      this.J.removeClass("left", "right", "center");
      this.J.fadeIn("fast");
      switch (position) {
        case "left":
        case "l":
          return this.J.addClass("left");
        case "right":
        case "r":
          return this.J.addClass("right");
        case "center":
        case "c":
          return this.J.addClass("center");
      }
    };

    return DialogCharacter;

  })(Widget);

  window.DialogBox = (function(_super) {
    __extends(DialogBox, _super);

    function DialogBox(game, alwaysontop) {
      var _this = this;
      if (alwaysontop == null) {
        alwaysontop = false;
      }
      DialogBox.__super__.constructor.call(this, Res.tpls['dialog-box']);
      this.game = game;
      this.db = game.db;
      this.onshow = false;
      this.displayInterval = null;
      this.displayLock = false;
      this.characters = {};
      this.currentCharacter = null;
      if (alwaysontop) {
        this.J.addClass("top");
      }
      this.UI['content-wrapper'].onclick = function() {
        if (_this.displayLock) {
          return _this.endDisplay();
        } else {
          _this.UI['continue-hint'].J.fadeOut("fast");
          if (_this.currentCharacter) {
            _this.currentCharacter.J.removeClass("speaking");
          }
          return _this.emit("next");
        }
      };
    }

    DialogBox.prototype.clearCharacters = function() {
      var name, w, _ref;
      _ref = this.characters;
      for (name in _ref) {
        w = _ref[name];
        w.remove();
        delete this.characters[name];
      }
      return this.currentCharacter = null;
    };

    DialogBox.prototype.setCharacter = function(name, options, callback) {
      var data, dspName, type, value;
      console.log("set character", name, options);
      data = this.db.characters.get(name);
      dspName = data.name;
      this.currentCharacter = this.characters[name];
      for (type in options) {
        value = options[type];
        switch (type) {
          case "in":
            if (!this.characters[name]) {
              this.characters[name] = new DialogCharacter(this.UI['character-tpl'].innerHTML, name, data);
              this.currentCharacter = this.characters[name];
              this.currentCharacter.appendTo(this.UI['character-section']);
              this.currentCharacter.getIn(value);
            } else {
              this.currentCharacter = this.characters[name];
            }
            break;
          case "out":
            if (!this.currentCharacter) {
              return console.error("no such character", name);
            }
            this.currentCharacter.getOut(value);
            delete this.characters[name];
            return;
          case "effect":
            if (!this.currentCharacter) {
              return console.error("no such character", name);
            }
            this.currentCharacter.useEffect(value);
            if (value === "shadow") {
              dspName = "???";
            }
        }
      }
      return this.setSpeaker(dspName);
    };

    DialogBox.prototype.setSpeaker = function(speaker) {
      if (speaker) {
        return this.UI.speaker.J.text("" + speaker + ":");
      } else {
        return this.UI.speaker.J.text(" ");
      }
    };

    DialogBox.prototype.endDisplay = function() {
      var text;
      window.clearInterval(this.displayInterval);
      this.displayLock = false;
      text = this.currentDisplayData.text;
      text = text.replace(/\|/g, "</br>");
      text = text.replace(/`/g, "");
      this.UI.text.innerHTML = text;
      if (this.nostop) {
        return this.emit("next");
      } else {
        return this.UI['continue-hint'].J.fadeIn("fast");
      }
    };

    DialogBox.prototype.display = function(data, callback) {
      var _this = this;
      if (this.displayLock) {
        this.endDisplay();
      }
      if (!data.text) {
        if (callback) {
          callback();
        }
        return;
      }
      if (!this.onshow || !$(".dialog-box").length > 0) {
        this.show(function() {
          return _this.display(data, callback);
        });
        return;
      }
      if (data.nostop) {
        this.nostop = true;
      } else {
        this.nostop = false;
      }
      if (data.speaker) {
        this.setSpeaker(data.speaker);
      }
      this.UI['continue-hint'].J.fadeOut("fast");
      if (callback) {
        this.once("next", callback);
      }
      this.displayLock = true;
      this.currentDisplayData = data;
      if (data.text.indexOf("!!") === 0 || data.text.indexOf("！！") === 0) {
        this.css3Animate("animate-pop");
        if (this.currentCharacter) {
          this.currentCharacter.css3Animate("animate-pop");
        }
        data.text = data.text.replace("!!", "").replace("！！", "");
      }
      if (this.currentCharacter) {
        this.currentCharacter.J.addClass("speaking");
      }
      return this.setDisplayInterval(data.text);
    };

    DialogBox.prototype.setDisplayInterval = function(text) {
      var arr, currentDelay, delay, index,
        _this = this;
      arr = text.split("");
      index = 0;
      this.UI.text.innerHTML = "";
      delay = 0;
      currentDelay = 0;
      return this.displayInterval = window.setInterval((function() {
        var c;
        if (delay && currentDelay < delay) {
          return currentDelay += 1;
        }
        delay = 0;
        currentDelay = 0;
        if (index < arr.length) {
          if (index === arr.length - 1) {
            delay = 3;
          }
          switch (arr[index]) {
            case "|":
            case "|":
              c = "</br>";
              break;
            case "`":
              c = "";
              break;
            case ",":
            case "，":
              if (index !== (arr.length - 1)) {
                delay = 2;
              }
              c = arr[index];
              break;
            case "!":
            case "！":
            case "。":
              if (index !== (arr.length - 1)) {
                delay = 2;
              }
              c = arr[index];
              break;
            default:
              c = arr[index];
          }
          _this.UI.text.innerHTML += c;
          return index += 1;
        } else {
          return _this.endDisplay();
        }
      }), 40);
    };

    DialogBox.prototype.show = function(callback) {
      var _this = this;
      if (this.onshow && $(".dialog-box").length > 0) {
        if (callback) {
          callback();
        }
        return;
      }
      this.onshow = true;
      this.J.hide();
      this.J.find(".character-box").hide();
      this.appendTo(this.UILayer.dom);
      this.J.find(".character-box").fadeIn(200);
      return this.J.fadeIn("fast", function() {
        if (callback) {
          return callback();
        }
      });
    };

    DialogBox.prototype.hide = function(callback) {
      var _this = this;
      if (!this.onshow) {
        return;
      }
      this.onshow = false;
      this.J.find(".character-box").fadeOut(200);
      return this.css3Animate.call(this.UI['content-wrapper'], "animate-pophide", function() {
        try {
          _this.remove();
        } catch (_error) {}
        if (callback) {
          return callback();
        }
      });
    };

    return DialogBox;

  })(Menu);

}).call(this);
