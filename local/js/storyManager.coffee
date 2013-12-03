class window.StoryStage extends Stage
  constructor:(game,storyData)->
    super game
    @game = game
    @bgLayer = new Layer()
    @menu = new Menu("<div></div>").show()
    @drawQueueAdd @bgLayer
    @dialogBox = new DialogBox game
    @storyData = storyData
    @currentStep = -1
    @nextStep()
    @endData = null
  nextStep:->
    @currentStep += 1
    line = @storyData[@currentStep]
    console.log "story next step",line
    #console.log line
    if not line
      return @storyEnd()
    if line.indexOf("<!") is 0 #for comment
      return @nextStep()
    if line.indexOf(">") is 0
      return @switchBg.apply this,line.replace(">","").split " "
    if line.indexOf("@") is 0
      return @switchSpeaker.apply this,line.replace("@","").split " "
    if line.indexOf(":") is 0
      return @runCommand.apply this,line.replace(":","").split " "
    @showDialog line
  storyEnd:->
    @dialogBox.clearCharacters()
    @menu.hide()
    @emit "storyEnd",@endData
  switchBg:(type,name,animateName,animateTime="fast")->
    console.log "switch bg",type,name
    @dialogBox.hide()
    switch type
      when "color"
        color = name
        @bgLayer.drawColor name
      when "img"
        imgName = name
        @bgLayer.setImg Res.imgs[name]
      else return console.error "invailid bg type",type
    return if not animateName
    switch animateName
      when "lookaround"
        s = Utils.getSize()
        @bgLayer.animate {x:-@bgLayer.width+s.width},1000,=>
          @bgLayer.setCallback 200,=>
            @bgLayer.animate {x:0},1000,=>
              @nextStep()
      else
        if not @bgLayer[animateName]
          return console.error "invailid animate name",animateName
        @bgLayer[animateName] animateTime,=>
          @nextStep()
  switchSpeaker:(character)->
    options = {}
    for a,index in arguments when index > 0
      parts = a.split ":"
      name = parts[0]
      value = parts[1] or true
      options[name] = value
    @dialogBox.setCharacter character,options
    @nextStep()
  runCommand:(commandName)->
    a = arguments
    switch commandName
      when "animate"
        animateName = a[1]
        animateTime = a[2] or "normal"
        if @bgLayer[animateName] 
          @bgLayer[animateName] animateTime,=>
            @nextStep()
          return true
        else console.error "invailid animate name",name
      when "sound","playSound"
        AudioManager.play a[1]
      when "battle"
        @initBattle a[1],a[2],a[3]
        return true
      when "nosound"
        AudioManager.mute()
      when "startMission"
        return @startMission a[1]
      when "completeMission"
        return @endMission a[1]
      when "end"
        @endData = 
          type:a[1]
          name:a[2]
          data:a[3]
      else console.error "invailid command name :",commandName
    @nextStep()
    return true
  startMission:(missionName)->
    mission = @game.missionManager.startMission missionName
    console.log "start mission"
    if not mission
      console.error "no such mission ",missionName
      @nextStep()
    else
      box = new MissionDetailsBox(@game).appendTo @menu
      box.J.addClass "top"
      box.showMissionDetails mission,=>
        @nextStep()
      box.setBtnText "确定"
  showDialog:(text)->
    @dialogBox.display text:text,=>
      @nextStep()
  initBattle:(areaName,monstersData,loseData)->
    console.log "battle",monstersData,loseData
    areaData = @game.db.areas.get areaName
    if not areaData
      return console.error "invailid battle area",areaName
    data =
      monsters:monstersData.split(",")
      bg:areaData.battlefieldBg
      story:true
    if loseData is "nolose"
      data.nolose = true
    @game.saveStage()
    bf = @game.switchStage "battle",data
    bf.on "win",=>
      @game.restoreStage()
      @nextStep()
    bf.on "lose",(evt)=>
      evt.handled = true
      if not loseData
        box = new PopupBox "战斗失败","剧情战斗失败！要再试一次吗？</br>点击取消返回家里"
        PopupBox.setCloseText "取消"
        box.show()
        box.on "accept",=>
          @game.popSavedStage()
          @initBattle areaName,monstersData,loseData
        box.on "close",=>
          @game.clearSavedStage()
          @game.switchStage "home"
      else
        console.log "story battle lose"
        
class window.StoryManager extends EventEmitter
  constructor:(game)->
    # 剧情格式
    # 剧情名 ***name
    # 切换角色 @name position（left/right/center）
    # 切换场景 >type（img/color） name（imgname/colorText） animateName animateTime
    # 运行其他命令 :commandName arguments
    # 包括 animate sound battle startMission completeMission unlockarea end
    @game = game
    @storyData = Res.tpls["story"]
    @storys = {}
    @initStoryData()
  initStoryData:->
    lines = @storyData.split "\n"
    currentArr = []
    for l in lines
      if l.indexOf("***") is 0
        name = l.replace("***","")
        @currentArr = @storys[name] = []
        continue
      @currentArr.push l
    console.log @storys
  showStory:(name)->
    storyData = @storys[name] 
    if not storyData then return console.error "cannot find story named #{name}"
    @game.saveStage()
    stage = @game.switchStage "story",storyData
    stage.on "storyEnd",(endData)=>
      @storyEnd name,endData
  storyEnd:(name,endData)->
    @game.player.storys.completed[name] = true
    @game.player.saveData()
    if not endData or not endData.type
      return @game.restoreStage()
    @game.popSavedStage()
    switch endData.type
      when "stage"
        @game.switchStage endData.name,endData.data
      when "story"
        @showStory endData.name
      else console.error "invailid story end data type",endData.type
    
