class HomeMenu extends Menu
  constructor:(floor)->
    super Res.tpls['home-menu']
    @floor = floor
  addFunctionBtn:(name,x,y,width,height,callback)->
    console.log "add function btn"
    
class Floor extends Layer
  constructor:(home)->
    super 0,0
    @home = home
    @camera = new Camera()
    @mainBg = null
    @drawQueueAdd @camera
    @layers = {}
    @currentX = 0
    @initMenu()
    @initLayers()
  initLayers:->
  initMenu:->
    s = Utils.getSize()
    @menu = new HomeMenu
    moveCallback = ()=>
      x = @currentX
      delete @camera.lock
      if x is 0
        @menu.UI['move-left'].J.fadeOut 130
      else
        @menu.UI['move-left'].J.fadeIn 130
      if x is (@mainBg.width - s.width)
        @menu.UI['move-right'].J.fadeOut 130
      else
        @menu.UI['move-right'].J.fadeIn 130
    @menu.UI['move-right'].onclick = (evt)=>
      evt.stopPropagation()
      console.log "right"
      @camera.lock = true
      @currentX += 400
      if @currentX > @mainBg.width - s.width then @currentX = @mainBg.width - s.width
      x = @camera.getOffsetPositionX @currentX,@mainBg
      if x > @mainBg.width then x = @mainBg.width
      @camera.animate {x:x},"normal",->
        moveCallback()
    @menu.UI['move-left'].onclick = (evt)=>
      evt.stopPropagation()
      console.log "left"
      @camera.lock = true
      @currentX -= 400
      if @currentX < 0 then @currentX = 0
      x = @camera.getOffsetPositionX @currentX,@mainBg
      @camera.animate {x:x},"normal",->
        moveCallback()
    
class FirstFloor extends Floor
  constructor:->
    super
    @currentX = 400
    @camera.x = @camera.getOffsetPositionX @currentX,@mainBg
  initLayers:->
    main = new Layer Res.imgs.homeDownMain
    float = new Layer Res.imgs.homeDownFloat
    @mainBg = main
    main.z = 300
    float.z = 0 
    float.fixToBottom()
    float.x = 1000
    @camera.render main,float
    @camera.defaultReferenceZ = main.z
    @layers =
      main:main
      float:float
  show:->
    @fadeIn "fast"
    @menu.show()
    
class SecondFloor extends Floor
  initLayers:->
    main = new Layer Res.imgs.homeDown
    @mainBg = main
    @layers =
      main:main
    @camera.render main
  showWorkTable:->
    worktable = new Worktable @home
    @onshow = false
    @home.drawQueueAddAfter worktable
    worktable.on "close",=>
      @home.drawQueueRemove worktable
      @onshow = true
      @menu.show()
    
class window.Home extends Stage
  constructor:(game)->
    super()
    @game = game
    @firstFloor = new FirstFloor this
    @secondFloor = new SecondFloor this
    @drawQueueAdd @firstFloor,@secondFloor
    @firstFloor.show()
  goUp:->
  goDown:->
  exit:->
    @clearDrawQueue()
    @game.switchStage "worldMap"
