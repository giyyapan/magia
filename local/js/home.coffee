class SubMenu extends Widget
  constructor:(tpl,menu)->
    super tpl
    @menu = menu
    @dom.onclick = =>
      @menu.showFunctionBtns()
      @hide()
  setTitle:(title)->
    @UI.title.J.text title
  hide:->
    @J.fadeOut "fast"
    @emit "hide"
  show:->
    @J.fadeIn "fast"
    @emit "show"
  addBtn:(name,btnCode)->
    btn = new Widget @UI['sub-btn-tpl'].innerHTML
    btn.UI.name.J.text name
    btn.appendTo @UI['sub-btn-box']
    btn.dom.onclick = (evt)=>
      evt.stopPropagation()
      data = autohide:true,showFunctionBtns:true
      @menu.emit "activeSubMenu",btnCode,data
      @hide() if data.autohide
      @menu.showFunctionBtns() if data.showFunctionBtns
      
class HomeMenu extends Menu
  constructor:(floor)->
    super Res.tpls['home-menu']
    @floor = floor
    @functionBtns = []
    @subMenu = new SubMenu @UI['sub-menu-layer'],this
  showFunctionBtns:->
    for btn in @functionBtns
      btn.J.removeClass "animate-popout"
      btn.css3Animate "animate-popup"
  hideFunctionBtns:->
    for btn in @functionBtns
      btn.J.addClass "animate-popout"
  addFunctionBtn:(name,x,y,callback)->
    btn = new Widget @UI['function-btn-tpl'].innerHTML
    @functionBtns.push btn
    btn.appendTo @UI['function-btn-box']
    btn.name = name
    btn.J.css left:"#{x}px",top:"#{y}px"
    btn.dom.onclick = ->
      callback() if callback
  showSubMenu:(title)->
    @hideFunctionBtns()
    @off "activeSubMenu"
    @subMenu.UI['sub-btn-box'].J.html ""
    @subMenu.setTitle title
    for name,index in arguments when index > 0
      @subMenu.addBtn name,index
    @subMenu.show()
      
class Floor extends Layer
  constructor:(home)->
    super 0,0
    @home = home
    @camera = new Camera()
    @mainBg = null
    @drawQueueAdd @camera
    @layers = {}
    @initMenu()
    @initLayers()
    @initFunctionBtns()
    @init()
  init:->
    @currentX = 0
    @camera.reset()
    @menu.show()
    @menu.showFunctionBtns()
  initFunctionBtns:->
    @camera.render @menu.UI['function-btn-box']
  initLayers:->
  initMenu:->
    s = Utils.getSize()
    @menu = new HomeMenu Res.tpls['home-menu']
    moveCallback = ()=>
      x = @currentX
      delete @camera.lock
      if x is 0
        @menu.UI['move-left'].J.removeClass("animate-popup").addClass "animate-popout"
      else
        @menu.UI['move-left'].J.removeClass("animate-popout").addClass "animate-popup"
      if x is (@mainBg.width - s.width)
        @menu.UI['move-right'].J.removeClass("animate-popup").addClass "animate-popout"
      else
        @menu.UI['move-right'].J.removeClass("animate-popout").addClass "animate-popup"
    @menu.UI['move-right'].onclick = (evt)=>
      evt.stopPropagation()
      console.log "right"
      @camera.lock = true
      @currentX += 400
      if @currentX > @mainBg.width - s.width then @currentX = @mainBg.width - s.width
      x = @camera.getOffsetPositionX @currentX,@mainBg
      if x > @mainBg.width then x = @mainBg.width
      @camera.animate {x:x},300,"swing",->
        moveCallback()
    @menu.UI['move-left'].onclick = (evt)=>
      evt.stopPropagation()
      console.log "left"
      @camera.lock = true
      @currentX -= 400
      if @currentX < 0 then @currentX = 0
      x = @camera.getOffsetPositionX @currentX,@mainBg
      @camera.animate {x:x},300,"swing",->
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
  initFunctionBtns:->
    super
    @menu.addFunctionBtn "上楼",173,20,=>
      @menu.showSubMenu "楼梯","上楼"
      @menu.on "activeSubMenu",(buttonCode,data)=>
        data.showFunctionBtns = false
        @home.goUp()
    @menu.addFunctionBtn "玄关",580,600,=>
      @menu.showSubMenu "玄关","出门"
      @menu.on "activeSubMenu",(buttonCode)=>
        @home.exit()
    @menu.addFunctionBtn "卧室",1154,98,=>
      @menu.showSubMenu "卧室","换衣服","睡觉"
      @menu.on "activeSubMenu",(buttonCode)=>
        switch buttonCode
          when 1 then console.log "换衣服"
          when 2 then alert "zzz"
    @menu.addFunctionBtn "猫",1548,425,=>
      @menu.showSubMenu "猫","调戏","对话"
      @menu.on "activeSubMenu",(buttonCode)=>
        switch buttonCode
          when 1 then alert "调戏你妹啊！"
          when 2 then alert "喵喵喵"
  show:->
    @fadeIn "fast"
    @menu.show()
    
class SecondFloor extends Floor
  constructor:->
    super
    @onshow = false
  initLayers:->
    main = new Layer Res.imgs.homeUp
    @mainBg = main
    @layers =
      main:main
    @camera.render main
  initFunctionBtns:->
    super
    @menu.addFunctionBtn "工作台",180,140,=>
      @menu.showSubMenu "工作台","素材加工"
      @menu.on "activeSubMenu",(buttonCode)=>
        switch buttonCode
          when 1 then @showWorkTable()
    @menu.addFunctionBtn "下楼",706,120,=>
      @menu.showSubMenu "楼梯","下楼"
      @menu.on "activeSubMenu",(buttonCode,data)=>
        data.showFunctionBtns = false
        @home.goDown()
  showWorkTable:->
    worktable = new Worktable @home
    @mainBg.onshow = false
    @drawQueueAdd worktable
    worktable.on "close",=>
      @drawQueueRemove worktable
      console.log "close"
      @mainBg.onshow = true
      @init()
      
class window.Home extends Stage
  constructor:(game)->
    super()
    @game = game
    @firstFloor = new FirstFloor this
    @secondFloor = new SecondFloor this
    @drawQueueAdd @firstFloor,@secondFloor
    @firstFloor.show()
  goDown:->
    @secondFloor.camera.animate x:200,y:-50,scale:1.4,200,=>
      @secondFloor.camera.animate x:"-=50",y:"+=50",330,"expoOut",=>
        @secondFloor.fadeOut 350
        @secondFloor.camera.animate x:"-=50",y:"+=50",330,"expoOut",=>
          @secondFloor.camera.animate x:"-=50",y:"+=50",330,"expoOut",=>
            @secondFloor.onshow = false
            @firstFloor.onshow = true
            @firstFloor.y = +300
            @firstFloor.transform.opacity = 0
            @firstFloor.animate {"transform.opacity":1,y:0},500,"expoOut"
            @firstFloor.init()
  goUp:->
    @firstFloor.camera.animate x:-250,y:-50,scale:1.4,200,=>
      @firstFloor.camera.animate x:"+=50",y:"-=50",330,"expoOut",=>
        @firstFloor.fadeOut 350
        @firstFloor.camera.animate x:"+=50",y:"-=50",330,"expoOut",=>
          @firstFloor.camera.animate x:"+=50",y:"-=50",330,"expoOut",=>
            @firstFloor.onshow = false
            @secondFloor.onshow = true
            @secondFloor.y = -300
            @secondFloor.transform.opacity = 0
            @secondFloor.animate {"transform.opacity":1,y:0},500,"expoOut"
            @secondFloor.init()
  exit:->
    @clearDrawQueue()
    @game.switchStage "worldMap"
