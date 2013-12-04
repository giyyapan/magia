// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.StoryStage = (function(_super) {
    __extends(StoryStage, _super);

    function StoryStage(game, storyData) {
      StoryStage.__super__.constructor.call(this, game);
      this.game = game;
      this.bgLayer = new Layer();
      this.menu = new Menu("<div></div>").show();
      this.drawQueueAdd(this.bgLayer);
      this.dialogBox = new DialogBox(game);
      this.storyData = storyData;
      this.currentStep = -1;
      this.nextStep();
      this.endData = null;
    }

    StoryStage.prototype.nextStep = function() {
      var line;
      this.currentStep += 1;
      line = this.storyData[this.currentStep];
      console.log("story next step", line);
      if (!line) {
        return this.storyEnd();
      }
      if (line.indexOf("<!") === 0) {
        return this.nextStep();
      }
      if (line.indexOf(">") === 0) {
        return this.switchBg.apply(this, line.replace(">", "").split(" "));
      }
      if (line.indexOf("@") === 0) {
        return this.switchSpeaker.apply(this, line.replace("@", "").split(" "));
      }
      if (line.indexOf(":") === 0) {
        return this.runCommand.apply(this, line.replace(":", "").split(" "));
      }
      return this.showDialog(line);
    };

    StoryStage.prototype.storyEnd = function() {
      this.dialogBox.clearCharacters();
      this.menu.hide();
      return this.emit("storyEnd", this.endData);
    };

    StoryStage.prototype.switchBg = function(type, name, animateName, animateTime) {
      var color, imgName, s,
        _this = this;
      if (animateName == null) {
        animateName = "fadeIn";
      }
      if (animateTime == null) {
        animateTime = "fast";
      }
      this.dialogBox.hide();
      switch (type) {
        case "color":
          color = name;
          console.log("switch bg color", name);
          this.bgLayer.drawColor(name);
          break;
        case "img":
          imgName = name;
          console.log("switch bg img", imgName);
          this.bgLayer.setImg(Res.imgs[imgName]);
          break;
        default:
          console.error("invailid type:", type);
      }
      switch (animateName) {
        case "lookaround":
          s = Utils.getSize();
          return this.bgLayer.animate({
            x: -this.bgLayer.width + s.width
          }, 1000, function() {
            return _this.bgLayer.setCallback(200, function() {
              return _this.bgLayer.animate({
                x: 0
              }, 1000, function() {
                return _this.nextStep();
              });
            });
          });
        default:
          if (!this.bgLayer[animateName]) {
            return console.error("invailid animate name", animateName);
          }
          return this.bgLayer[animateName](animateTime, function() {
            return _this.nextStep();
          });
      }
    };

    StoryStage.prototype.switchSpeaker = function(character) {
      var a, index, name, options, parts, value, _i, _len;
      options = {};
      for (index = _i = 0, _len = arguments.length; _i < _len; index = ++_i) {
        a = arguments[index];
        if (!(index > 0)) {
          continue;
        }
        parts = a.split(":");
        name = parts[0];
        value = parts[1] || true;
        options[name] = value;
      }
      this.dialogBox.setCharacter(character, options);
      return this.nextStep();
    };

    StoryStage.prototype.runCommand = function(commandName) {
      var a, animateName, animateTime,
        _this = this;
      a = arguments;
      switch (commandName) {
        case "animate":
          animateName = a[1];
          animateTime = a[2] || "normal";
          if (this.bgLayer[animateName]) {
            this.bgLayer[animateName](animateTime, function() {
              return _this.nextStep();
            });
            return true;
          } else {
            console.error("invailid animate name", name);
          }
          break;
        case "sound":
        case "playSound":
          AudioManager.play(a[1]);
          break;
        case "battle":
          this.initBattle(a[1], a[2], a[3]);
          return true;
        case "nosound":
          AudioManager.mute();
          break;
        case "startMission":
          return this.startMission(a[1]);
        case "completeMission":
          return this.endMission(a[1]);
        case "end":
          this.endData = {
            type: a[1],
            name: a[2],
            data: a[3]
          };
          break;
        default:
          console.error("invailid command name :", commandName);
      }
      this.nextStep();
      return true;
    };

    StoryStage.prototype.startMission = function(missionName) {
      var box, mission,
        _this = this;
      mission = this.game.missionManager.startMission(missionName);
      console.log("start mission");
      if (!mission) {
        console.error("no such mission ", missionName);
        return this.nextStep();
      } else {
        box = new MissionDetailsBox(this.game).appendTo(this.menu);
        box.J.addClass("top");
        box.showMissionDetails(mission, function() {
          return _this.nextStep();
        });
        return box.setBtnText("确定");
      }
    };

    StoryStage.prototype.showDialog = function(text) {
      var _this = this;
      return this.dialogBox.display({
        text: text
      }, function() {
        return _this.nextStep();
      });
    };

    StoryStage.prototype.initBattle = function(areaName, monstersData, loseData) {
      var areaData, bf, data,
        _this = this;
      console.log("battle", monstersData, loseData);
      areaData = this.game.db.areas.get(areaName);
      if (!areaData) {
        return console.error("invailid battle area", areaName);
      }
      data = {
        monsters: monstersData.split(","),
        bg: areaData.battlefieldBg,
        story: true
      };
      if (loseData === "nolose") {
        data.nolose = true;
      }
      this.game.saveStage();
      bf = this.game.switchStage("battle", data);
      bf.on("win", function() {
        _this.game.restoreStage();
        return _this.nextStep();
      });
      return bf.on("lose", function(evt) {
        var box;
        evt.handled = true;
        if (!loseData) {
          box = new PopupBox("战斗失败", "剧情战斗失败！要再试一次吗？</br>点击取消返回家里");
          PopupBox.setCloseText("取消");
          box.show();
          box.on("accept", function() {
            _this.game.popSavedStage();
            return _this.initBattle(areaName, monstersData, loseData);
          });
          return box.on("close", function() {
            _this.game.clearSavedStage();
            return _this.game.switchStage("home");
          });
        } else {
          return console.log("story battle lose");
        }
      });
    };

    return StoryStage;

  })(Stage);

  window.StoryManager = (function(_super) {
    __extends(StoryManager, _super);

    function StoryManager(game) {
      this.game = game;
      this.storyData = Res.tpls["story"];
      this.storys = {};
      this.initStoryData();
    }

    StoryManager.prototype.initStoryData = function() {
      var currentArr, l, lines, name, _i, _len;
      lines = this.storyData.split("\n");
      currentArr = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        l = lines[_i];
        if (l.indexOf("***") === 0) {
          name = l.replace("***", "");
          this.currentArr = this.storys[name] = [];
          continue;
        }
        this.currentArr.push(l);
      }
      return console.log(this.storys);
    };

    StoryManager.prototype.showStory = function(name, callback) {
      var stage, storyData,
        _this = this;
      storyData = this.storys[name];
      if (!storyData) {
        return console.error("cannot find story named " + name);
      }
      this.game.saveStage();
      stage = this.game.switchStage("story", storyData);
      return stage.on("storyEnd", function(endData) {
        return _this.storyEnd(name, endData, callback);
      });
    };

    StoryManager.prototype.storyEnd = function(name, endData, callback) {
      this.game.player.storys.completed[name] = true;
      this.game.player.saveData();
      if (!endData || !endData.type) {
        if (callback) {
          callback();
        } else {
          this.game.restoreStage();
        }
        return;
      }
      this.game.popSavedStage();
      if (endData.type === "story") {
        return this.showStory(endData.name, callback);
      } else {
        if (callback) {
          return callback();
        } else {
          switch (endData.type) {
            case "stage":
              return this.game.switchStage(endData.name, endData.data);
            default:
              return console.error("invailid story end data type", endData.type);
          }
        }
      }
    };

    return StoryManager;

  })(EventEmitter);

}).call(this);
