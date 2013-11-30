// Generated by CoffeeScript 1.6.2
(function() {
  var Mission,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Mission = (function(_super) {
    __extends(Mission, _super);

    function Mission(manager, name, data) {
      Mission.__super__.constructor.call(this, null);
      this.name = name;
      this.data = data;
      this.manager = manager;
      this.game = manager.game;
      this.player = this.game.player;
      this.dspName = data.name;
      this.completed = false;
      this.requests = {};
      this.status = this.getStatus();
      this.incompletedRequests = {};
      this.initRequests();
    }

    Mission.prototype.initRequests = function() {
      var monsters, name, number, p, places, t, things, value, _i, _j, _k, _len, _len1, _len2, _ref;

      _ref = this.data.requests;
      for (name in _ref) {
        value = _ref[name];
        switch (name) {
          case "get":
            this.requests.get = {};
            things = value.split(",");
            for (_i = 0, _len = things.length; _i < _len; _i++) {
              t = things[_i];
              if (t.indexOf("*") > -1) {
                name = t.split("*")[0];
                number = parseInt(t.split("*")[1]);
              } else {
                name = t;
                number = 1;
              }
              this.requests.get[name] = parseInt(number);
            }
            break;
          case "visit":
            this.requests.visit = {};
            places = value.split(",");
            for (_j = 0, _len1 = places.length; _j < _len1; _j++) {
              p = places[_j];
              this.requests.visit[p] = true;
            }
            break;
          case "kill":
            this.requests.kill = {};
            monsters = value.split(",");
            for (_k = 0, _len2 = monsters.length; _k < _len2; _k++) {
              t = monsters[_k];
              if (t.indexOf("*") > -1) {
                name = t.split("*")[0];
                number = parseInt(t.split("*")[1]);
              } else {
                name = t;
                number = 1;
              }
              this.requests.kill[name] = parseInt(number);
            }
        }
      }
      if (this.status === "current" || this.status === "avail") {
        this.incompletedRequests = Utils.clone(this.requests, true);
        console.log("init requests", this.requests);
        return this.initIncompletedRequests();
      } else {
        return this.incompletedRequests = {};
      }
    };

    Mission.prototype.initIncompletedRequests = function() {
      var hasNumber, name, number, obj, pcr, type, value, _ref, _ref1, _ref2;

      pcr = this.player.missions.current[this.name];
      if (!pcr) {
        return false;
      }
      _ref = this.incompletedRequests;
      for (type in _ref) {
        obj = _ref[type];
        if (pcr[type]) {
          _ref1 = pcr[type];
          for (name in _ref1) {
            value = _ref1[name];
            if (value === true) {
              delete obj[name];
            }
            if (typeof value === "number") {
              obj[name] -= value;
              if (obj[name] <= 0) {
                delete obj[name];
              }
            }
          }
        }
      }
      if (this.incompletedRequests.get) {
        _ref2 = this.incompletedRequests.get;
        for (name in _ref2) {
          number = _ref2[name];
          hasNumber = this.player.hasThing(name);
          if (hasNumber) {
            this.update("get", {
              name: name,
              number: hasNumber
            });
          }
        }
      }
      return console.log(this.incompletedRequests);
    };

    Mission.prototype.update = function(type, data) {
      var ir, monsterName, number, pcr, placeName, thingName, _i, _len;

      ir = this.incompletedRequests;
      pcr = this.player.missions.current[this.name];
      if (!pcr) {
        return console.error("player no request data", this.name);
      }
      if (!ir[type]) {
        return false;
      }
      switch (type) {
        case "kill":
          console.log("enter kill");
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            monsterName = data[_i];
            if (!ir.kill[monsterName]) {
              continue;
            }
            ir.kill[monsterName] -= 1;
            if (ir.kill[monsterName] <= 0) {
              delete ir.kill[monsterName];
            }
            pcr.kill[monsterName] += 1;
          }
          break;
        case "get":
          thingName = data.name;
          number = data.number || 1;
          if (ir.get[thingName]) {
            ir.get[thingName] -= 1;
            if (ir.get[thingName] <= 0) {
              delete ir.get[thingName];
            }
            pcr.get[thingName] += 1;
          }
          break;
        case "visit":
          placeName = data;
          delete ir.visit[placeName];
          pcr.visit[placeName] = true;
          console.log(ir);
      }
      return this.checkComplete();
    };

    Mission.prototype.checkComplete = function() {
      var data, name, type, value, _ref;

      if (this.completed === true) {
        return true;
      }
      _ref = this.incompletedRequests;
      for (type in _ref) {
        data = _ref[type];
        for (name in data) {
          value = data[name];
          return false;
        }
      }
      this.completed = true;
      if (this.data.autoComplete) {
        this.autoFinish();
      }
      return true;
    };

    Mission.prototype.getStatus = function() {
      var player;

      player = this.player;
      if (player.missions.current[this.name] !== void 0) {
        return this.status = "current";
      }
      if (player.missions.finished[this.name] !== void 0) {
        return this.status = "finished";
      }
      if (this.isAvailable()) {
        return this.status = "avail";
      } else {
        return this.status = "disable";
      }
    };

    Mission.prototype.autoFinish = function() {
      var box,
        _this = this;

      console.log("autofinish");
      box = new PopupBox("任务信息", "任务 " + this.dspName + " 已经完成", function() {
        return _this.finish();
      });
      return box.hideCloseBtn();
    };

    Mission.prototype.start = function() {
      console.log("mission start");
      if (!this.isAvailable()) {
        console.error("not availe!", this);
        return false;
      }
      this.player.missions.current[this.name] = this.getNewMissionData();
      this.status = "current";
      this.handleStartData();
      this.player.saveData();
      return true;
    };

    Mission.prototype.finish = function() {
      delete this.player.missions.current[this.name];
      this.player.missions.finished[this.name] = true;
      this.status = "finished";
      this.handleEndData();
      this.palyer.saveData();
      return true;
    };

    Mission.prototype.handleEndData = function() {
      var data, type, _ref, _results;

      if (!this.data.end) {
        return false;
      }
      _ref = this.data.end;
      _results = [];
      for (type in _ref) {
        data = _ref[type];
        switch (type) {
          case "story":
            _results.push(this.game.storyManager.showStory(data));
            break;
          case "onloackarea":
            _results.push(this.player.onloackedAreas[data] = true);
            break;
          default:
            _results.push(void 0);
        }
      }
      return _results;
    };

    Mission.prototype.handleStartData = function() {
      var data, type, _ref, _results;

      if (!this.data.start) {
        return false;
      }
      _ref = this.data.start;
      _results = [];
      for (type in _ref) {
        data = _ref[type];
        switch (type) {
          case "story":
            _results.push(this.game.storyManager.showStory(data));
            break;
          case "onloackarea":
            _results.push(this.player.onloackedAreas[data] = true);
            break;
          default:
            _results.push(void 0);
        }
      }
      return _results;
    };

    Mission.prototype.getNewMissionData = function() {
      var data, name, obj, type, value, _ref, _ref1;

      obj = {};
      _ref = this.requests;
      for (type in _ref) {
        data = _ref[type];
        obj[type] = {};
        _ref1 = this.request;
        for (name in _ref1) {
          value = _ref1[name];
          if (value === true) {
            obj[type][name] = false;
            continue;
          }
          if (!isNaN(value)) {
            obj[type][name] = 0;
          } else {
            console.error("invailid request data : ", name, this);
          }
        }
      }
      return obj;
    };

    Mission.prototype.isAvailable = function() {
      if (this.data.after) {
        if (!this.player.missions.finished[this.data.after]) {
          return false;
        }
      }
      return true;
    };

    return Mission;

  })(EventEmitter);

  window.MissionManager = (function(_super) {
    __extends(MissionManager, _super);

    function MissionManager(game) {
      var data, name, _ref,
        _this = this;

      MissionManager.__super__.constructor.call(this, null);
      this.game = game;
      this.player = game.player;
      this.missions = {};
      _ref = this.game.db.missions.getAll();
      for (name in _ref) {
        data = _ref[name];
        this.missions[name] = new Mission(this, name, data);
      }
      console.log(this.missions);
      this.game.on("switchStage", function(newStage) {
        console.log("on switch stage fired");
        return _this.handleSwitchStage(newStage);
      });
      this.game.player.on("getThing", function(type, thing) {
        return _this.updateCurrentMissions("get", thing);
      });
    }

    MissionManager.prototype.handleSwitchStage = function(newStage) {
      var _this = this;

      switch (newStage.stageName) {
        case "battle":
          return newStage.on("win", function(data) {
            console.log("fuck win", data, data.monsters);
            return _this.updateCurrentMissions("kill", data.monsters);
          });
        case "area":
        case "shop":
          return this.updateCurrentMissions("visit", newStage.switchStageData);
        case "home":
        case "guild":
          return this.updateCurrentMissions("visit", newStage.stageName);
      }
    };

    MissionManager.prototype.updateCurrentMissions = function(type, data) {
      var mission, name, _ref;

      _ref = this.missions;
      for (name in _ref) {
        mission = _ref[name];
        if (mission.status === "current") {
          mission.update(type, data);
        }
      }
      this.player.saveData();
      return console.log(this.player);
    };

    MissionManager.prototype.startMission = function(mission) {
      var name;

      if (typeof mission === "string") {
        name = mission;
        mission = this.missions[name];
      }
      if (!mission) {
        return console.error("invailid mission :", mission);
      }
      return mission.start();
    };

    MissionManager.prototype.getMissions = function(type) {
      var mission, name, res, _ref, _ref1, _ref2, _ref3;

      res = [];
      switch (type) {
        case "all":
          _ref = this.missions;
          for (name in _ref) {
            mission = _ref[name];
            res.push(mission);
          }
          break;
        case "finished":
          _ref1 = this.missions;
          for (name in _ref1) {
            mission = _ref1[name];
            if (mission.getStatus() === "finished") {
              res.push(mission);
            }
          }
          break;
        case "current":
          _ref2 = this.missions;
          for (name in _ref2) {
            mission = _ref2[name];
            if (mission.getStatus() === "current") {
              res.push(mission);
            }
          }
          break;
        case "avail":
          _ref3 = this.missions;
          for (name in _ref3) {
            mission = _ref3[name];
            if (mission.getStatus() === "avail") {
              res.push(mission);
            }
          }
      }
      return res;
    };

    return MissionManager;

  })(EventEmitter);

}).call(this);
