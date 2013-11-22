// Generated by CoffeeScript 1.6.1
(function() {
  var AudioManager, GameAudio,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  AudioManager = (function(_super) {

    __extends(AudioManager, _super);

    function AudioManager() {
      var name, path, resourceContainerDom, _ref, _ref1;
      AudioManager.__super__.constructor.apply(this, arguments);
      this.source = {
        sfxStartCusor: "sfxStartCusor"
      };
      this.bgmSource = {
        startMenu: "startMenu",
        home: "home"
      };
      this.audios = {};
      resourceContainerDom = document.getElementById("resourceContainer");
      _ref = this.source;
      for (name in _ref) {
        path = _ref[name];
        this.audios[name] = new GameAudio(name, path, resourceContainerDom, false);
      }
      _ref1 = this.bgmSource;
      for (name in _ref1) {
        path = _ref1[name];
        this.audios[name] = new GameAudio(name, path, resourceContainer, true);
      }
    }

    AudioManager.prototype.play = function(audioName) {
      if (this.audios[audioName]) {
        return this.audios[audioName].play();
      } else {
        return console.error("not found audio");
      }
    };

    AudioManager.prototype.soundOff = function() {
      return this.setSound("all", 0);
    };

    AudioManager.prototype.soundOn = function() {
      return this.setSound("all", 1);
    };

    AudioManager.prototype.setSound = function(soundName, volume) {
      var audio, _i, _len, _ref, _results;
      if (soundName === "all") {
        _ref = this.audios;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          audio = _ref[_i];
          _results.push(audio.setVolume(volume));
        }
        return _results;
      } else {
        if (this.audios[soundName]) {
          return this.audios[soundName].setVolume(volume);
        }
      }
    };

    AudioManager.prototype.pause = function(audioName) {
      if (this.audios[audioName]) {
        return this.audios[audioName].pause();
      } else {
        return console.error("pause-audio" + audioName + "not found ");
      }
    };

    AudioManager.prototype.stop = function(audioName) {
      if (this.audios[audioName]) {
        return this.audios[audioName].stop();
      } else {
        return console.error("stop-audio" + audioName + "not found ");
      }
    };

    AudioManager.prototype.mute = function() {
      var audioName, _i, _len, _ref, _results;
      _ref = this.audios;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        audioName = _ref[_i];
        _results.push(this.audios[audioName].stop());
      }
      return _results;
    };

    return AudioManager;

  })(EventEmitter);

  GameAudio = (function(_super) {

    __extends(GameAudio, _super);

    function GameAudio(name, sourceName, container, isBGM) {
      this.name = name;
      this.sourceName = sourceName;
      this.container = container;
      this.isBGM = isBGM;
      GameAudio.__super__.constructor.apply(this, arguments);
      this.pathName = "/audio/";
      this.doms = [];
      if (this.isBGM) {
        this.stoped = false;
        this.play = this.bgmPlay;
      } else {
        this.play = this.soundPlay;
      }
      this.addAudioDom();
    }

    GameAudio.prototype.addAudioDom = function() {
      var newAudioDom, oggSource;
      newAudioDom = document.createElement("audio");
      newAudioDom.id = this.name + (this.doms.length + 1);
      newAudioDom.preload = "preload";
      if (this.isBGM) {
        newAudioDom.loop = "loop";
      }
      this.container.appendChild(newAudioDom);
      this.doms.push(newAudioDom);
      oggSource = document.createElement("source");
      oggSource.id = newAudioDom.id + "ogg";
      oggSource.src = this.pathName + this.name + ".ogg";
      newAudioDom.appendChild(oggSource);
      return newAudioDom;
    };

    GameAudio.prototype.soundPlay = function() {
      var soundDom, _i, _len, _ref;
      _ref = this.doms;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        soundDom = _ref[_i];
        console.log(soundDom.paused, soundDom.id);
        if (soundDom.paused) {
          console.log("soundPlay hehe");
          console.log(soundDom);
          soundDom.currentTime = 0;
          soundDom.play();
          return true;
        }
      }
      this.addAudioDom().play();
      console.log("playSOUND");
      return false;
    };

    GameAudio.prototype.bgmPlay = function() {
      this.doms[0].play();
      this.doms[0].paused = false;
      return console.log("playBGM");
    };

    GameAudio.prototype.setVolume = function(volume) {
      var soundDom, _i, _len, _ref, _results;
      _ref = this.doms;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        soundDom = _ref[_i];
        _results.push(soundDom.volume = volume);
      }
      return _results;
    };

    GameAudio.prototype.stop = function() {
      var soundDom, _i, _len, _ref, _results;
      _ref = this.doms;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        soundDom = _ref[_i];
        soundDom.pause();
        _results.push(soundDom.currentTime = 0);
      }
      return _results;
    };

    GameAudio.prototype.pause = function() {
      var soundDom, _i, _len, _ref, _results;
      _ref = this.doms;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        soundDom = _ref[_i];
        _results.push(soundDom.pause());
      }
      return _results;
    };

    return GameAudio;

  })(EventEmitter);

  window.myAudio = new AudioManager();

}).call(this);
