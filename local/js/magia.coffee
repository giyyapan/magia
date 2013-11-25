class Magia
  constructor:->
    @size = null
    @res = null
    @canvas = new Suzaku.Widget("#gameCanvas")
    @UILayer = new Suzaku.Widget("#UILayer")
    @handleDisplaySize()
    @km = new Suzaku.KeybordManager()
    @player = null
    @db = null
    window.Key = @km.init()
    window.onresize = =>
      @handleDisplaySize()
    @loadResources =>
      #window.myAudio.play "startMenu"
      @db = new Database()
      @player = new Player null,@db
      $("#loadingPage").slideUp "slow"
      @switchStage "start"
      #window.myAudio.stop "startMenu"
      #window.myAudio.play "home"
      #@switchStage "worldMap"
      #@switchStage "area","forest"
      #@switchStage "home"
      @startGameLoop()
  switchStage:(stage,data)->
    console.log "init stage:",stage
    switch stage
      when "start" 
        s = new StartMenu this,data
        window.myAudio.play "startMenu"
      when "home" 
        s = new Home this,data
        window.myAudio.play "home"
      when "test" then s = new TestStage this,data
      when "town" then s = new Town this,data
      when "area" then s = new Area this,data
      when "worldMap" then s = new WorldMap this,data
      else console.error "invailid stage:#{stage}"
    if @currentStage
      @currentStage.hide =>
        @currentStage = s
        s.show()
    else
      @currentStage = s
      s.show()
  startGameLoop:->
    self = this
    window.requestAnimationFrame ->
      self.tick()
      self = null
  tick:->
    self = this
    @lastTickTime = @nowTickTime or 0
    now = new Date().getTime()
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
    
