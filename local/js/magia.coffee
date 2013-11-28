class Magia
  constructor:->
    @size = null
    @res = null
    @canvas = new Suzaku.Widget("#gameCanvas")
    @UILayer = new Suzaku.Widget("#UILayer")
    @handleDisplaySize()
    @km = new Suzaku.KeybordManager()
    @savedStageStack = []
    @player = null
    @missionManager = null
    @storyManager = null
    @db = null
    window.Key = @km.init()
    window.onresize = =>
      @handleDisplaySize()
    @loadResources =>
      #window.AudioManager.play "startMenu"
      @db = new Database()
      @player = new Player @db
      @missionManager = new MissionManager this
      @storyManager = new StoryManager this
      $("#loadingPage").slideUp "slow"
      window.AudioManager.stop "startMenu"
      window.AudioManager.play "home"
      @switchStage "start"
      #@switchStage "worldMap"
      #@switchStage "area","forest"
      #@switchStage "shop","magicItemShop"
      #@switchStage "guild" 
      #@switchStage "home"
      @startGameLoop()
  switchStage:(stage,data)->
    console.log "init stage:",stage
    if typeof stage.tick is "function"
      s = stage
    else
      switch stage
        when "start" 
          s = new StartMenu this,data
          window.AudioManager.play "startMenu"
        when "home" 
          s = new Home this,data
          window.AudioManager.play "home"
        when "test" then s = new TestStage this,data
        when "area" then s = new Area this,data
        when "shop" then s = new Shop this,data
        when "guild" then s = new Guild this,data
        when "story" then s = new StoryStage this,data
        when "battle" then s = new Battlefield this,data
        when "worldMap" then s = new WorldMap this,data
        else console.error "invailid stage:#{stage}"
    if @currentStage
      @currentStage.hide =>
        @currentStage = s
        s.show()
    else
      @currentStage = s
      s.show()
    return s
  clearSavedStage:->
    @savedStageStack = []
    return true
  popSavedStage:->
    return @savedStageStack.pop()
  saveStage:->
    return @savedStageStack.push @currentStage
  restoreStage:->
    if @savedStageStack.length is 0
      console.error "restore stage from empty stack!"
      return false
    @currentStage = @savedStageStack.pop()
    @currentStage.show()
    @currentStage.menu.show() if @currentStage.menu
    return true
  startGameLoop:->
    self = this
    window.requestAnimationFrame ->
      self.tick()
      self = null
    return true
  tick:->
    self = this
    now = new Date().getTime()
    @lastTickTime = @nowTickTime or now - 5
    tickDelay =  now - @lastTickTime
    fps = 1000/tickDelay
    if window.GameConfig.maxFPS and fps > window.GameConfig.maxFPS
      window.setTimeout (->
        self.tick()
        self = null
        ),10
      return
    @nowTickTime = now
    context = @canvas.dom.getContext "2d"
    @clearCanvas context
    if @currentStage
      @currentStage.tick tickDelay
      @currentStage.onDraw context,tickDelay
    if window.GameConfig.showFPS
      context.fillStyle = "white"
      context.font = "30px Arail"
      context.fillText "fps:#{parseInt fps}",10,30
    window.requestAnimationFrame ->
      self.tick()
      self = null
  clearCanvas:(context)->
    s = Utils.getSize()
    context.clearRect 0,0,s.width,s.height
  go:(step)->
    #go foward or backward  
  handleDisplaySize:->
    window.screen.lockOrientation "landscape" if window.screen.lockOrientation
    s =
      screenWidth:window.innerWidth
      screenHeight:window.innerHeight
      width:GameConfig.screen.width
      height:GameConfig.screen.height
      scaleX:1
      scaleY:1
    Utils.getSize = ->
      return s
    if (s.screenWidth/s.screenHeight) < (s.width/s.height)
      targetWidth = s.screenWidth
      targetHeight = targetWidth/s.width * s.height
    else
      targetHeight = s.screenHeight
      targetWidth = targetHeight/s.height * s.width
    w = Utils.sliceNumber targetWidth/s.width,3
    h = Utils.sliceNumber targetHeight/s.height,3
    s.scaleX = w
    s.scaleY = h
    J = $(".screen")
    J.css "left",parseInt((s.screenWidth-targetWidth)/2)+"px"
    Utils.setCSS3Attr J,"transform","scale(#{w},#{h})"
    Utils.setCSS3Attr J,"transform-origin","#{0}px 0"
  loadResources:(callback)->
    loadingPage = new Suzaku.Widget "#loadingPage"
    rm = new ResourceManager()
    rm.setPath "img","img/"
    for name,src of window.Imgs
      rm.useImg name,src
    rm.setPath "sprite","img/sprites/"
    for name,src of window.Sprites
      rm.useSprite name,src
    rm.setPath "template","templates/"
    for tpl in window.Templates
      rm.useTemplate tpl
    rm.on "loadOne",(total,loaded,type)=>
      percent = loaded/total*100
      loadingPage.UI.percent.innerText = "#{parseInt percent}%"
    rm.start =>
      window.Res = rm.loaded
      window.Res.tpls = window.Res.templates
      callback()
    
window.onload = ->
  magia = new Magia()
    
