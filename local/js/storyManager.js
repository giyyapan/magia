// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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
      console.log("hahahahahah");
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

    StoryManager.prototype.showStory = function(name) {
      return console.log("show story", name);
    };

    return StoryManager;

  })(EventEmitter);

}).call(this);
