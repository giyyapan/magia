class AudioManager extends EventEmitter
  constructor: ->
    super
    @source = 
      sfxStartCusor:"sfxStartCusor"
      startClick:"startClick"
    @bgmSource=
      startMenu:"startMenu"
      home:"home"
    @audios = {}      
    resourceContainerDom = document.getElementById("resourceContainer")
    for name,path of @source
      @audios[name] = new GameAudio name,path,resourceContainerDom,false
    for name,path of @bgmSource
      @audios[name] = new GameAudio name,path,resourceContainer,true
  play:(audioName)->
    return true if GameConfig.noSound
    if @audios[audioName].isBGM
      for audio of @audios
        if @audios[audio].isBGM
          @audios[audio].stop()
      @audios[audioName].play()
    else if @audios[audioName].isBGM is false
      @audios[audioName].play()
    else
      console.error "not found audio"
  soundOff:->
    @setSound "all",0
  soundOn: ->
    @setSound "all",1
  setSound:(soundName,volume) ->
    if soundName is "all"
      for audio of @audios
        @audios[audio].setVolume volume
    else 
      @audios[soundName].setVolume volume if @audios[soundName]
  pause:(audioName)->
    if @audios[audioName]
      @audios[audioName].pause()
    else
      console.error "pause-audio" + audioName + "not found "
  stop:(audioName)->
    if @audios[audioName]
      @audios[audioName].stop()
    else
      console.error "stop-audio" + audioName + "not found "
  mute:->
    for audio of @audios
      @audios[audio].stop()

class GameAudio extends EventEmitter
  constructor:(@name,@sourceName,@container,@isBGM) ->
    super
    @pathName = "/audio/"
    @doms = [];
    if @isBGM
      @stoped = false
      @play = @bgmPlay
    else
      @play = @soundPlay
    @addAudioDom()
  addAudioDom:->
    newAudioDom = document.createElement "audio"
    newAudioDom.id = @name + (@doms.length + 1)
    newAudioDom.preload = "preload"
    if @isBGM
      newAudioDom.loop = "loop"
    @container.appendChild newAudioDom
    @doms.push newAudioDom
  
    #init source
    oggSource = document.createElement "source"
    oggSource.id = newAudioDom.id + "ogg"
    oggSource.src = @pathName + @name + ".ogg"
    newAudioDom.appendChild oggSource
    return newAudioDom
  soundPlay:->
    for soundDom in @doms
      if soundDom.paused
        soundDom.currentTime = 0
        soundDom.play()
        return true
    @addAudioDom().play()
    return false
  bgmPlay:->
    @doms[0].play()
    @doms[0].paused = false
  setVolume:(volume)->
    for soundDom in @doms
      soundDom.volume = volume
  stop:->
    for soundDom in @doms
      soundDom.pause()
      soundDom.currentTime = 0
  pause:->
    for soundDom in @doms
      soundDom.pause()
    
    
window.myAudio = new AudioManager()
#window.myAudio.play "startMenu"
#window.myAudio.play "sfxStartCusor"
