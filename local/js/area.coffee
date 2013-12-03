class GatherResaultBox extends PopupBox
  constructor:(data)->
    super null
    @UI.title.J.text "采集结果"
    @hideAcceptBtn()
    if not data
      @UI.content.J.text "这里已经没有东西了，下次再来吧。"
    else
      playerItem = data
      @UI.img.J.show()
      @UI.img.src = data.img.src if data.img
      @UI.content.J.text "采集到了 #{data.dspName} x 1"

class MovePoint extends Widget
  constructor:(place,tpl,data)->
    @place = place
    @area = place.area
    parts = data.split ":"
    @moveTarget = parts[0]
    @x = parseInt parts[1].split(",")[0]
    @y = parseInt parts[1].split(",")[1]
    @guardians = null
    super tpl
    if @moveTarget is "exit"
      @text = "离开"
    else
      @text = @area.originData.places[@moveTarget].name
    @UI.target.J.text @text
    @J.addClass "mp-"+@moveTarget
    @J.css left:"#{@x}px",top:"#{@y}px"
    self = this
    @dom.onclick = (evt)=>
      evt.myOffsetX = evt.offsetX + @x - @place.currentX
      evt.myOffsetY = evt.offsetY + @y
      @active evt
  active:(evt)->
    if @guardians
      evt.stopPropagation()
      box = new PopupBox "警告","这个入口由 <strong>强大的怪物</strong> 把守，必须战胜他们才能通过。</br> 是否战斗？",=>
        @place.once "battleWin",=>
          @guardians = null
          @UI.guardians.J.hide()
        box.setAcceptText "来战"
        box.setCloseText "算了"
        box.show()
        @place.encounterMonster @guardians
    else
      @area.setCallback 300,=>
        @area.enterPlace @moveTarget
  setGuardians:(data)->
    @UI.guardians.J.show()
    @guardians = data.split ","

class ResPoint extends Widget
  constructor:(place,tpl,data,index)->
    super tpl
    @place = place
    @db = place.db
    @data = data
    @index = index
    @number = index + 1
    @pointText = "采集点#{index+1}"
    @UI.name.J.text @pointText
    parts = data.split " "
    @items = []
    @hasBoss = false
    itemsData = parts[1]
    switch itemsData
      when "none","null",undefined
        @items = null
      else
        @initItems itemsData
    monsterData = parts[2]
    isBoss = parts[3]
    switch monsterData
      when "none","null",undefined
        @monsters = null
      else
        @monsters = monsterData.split ','
        if isBoss
          @UI.boss.J.show()
          @hasBoss = true
        else @UI.monster.J.show()
    @dom.number = index+1
    @J.addClass "gp#{index+1}"
    position = parts[0]
    @J.css left:position.split(",")[0]+"px",top:position.split(",")[1]+"px",
    @dom.onclick = (evt)=>
      evt.stopPropagation()
      if @monsters and @monsters.length > 0
        text = if @hasBoss then "<strong>强大的怪物</strong>" else "怪物"
        if @items
          box = new PopupBox "采集","这里有#{text}把守，需要打败他们才能采集。</br>要战斗吗？"
        else
          box = new PopupBox "战斗","这里是怪物的栖息地。</br>要和怪物战斗吗？"
        box.setCloseText "算了"
        box.setAcceptText "来战"
        box.show()
        box.on "accept",=>
          @emit "active",@active()
      else
        new MsgBox "采集","采集中...",600,=>
          @emit "active",@active()
  initItems:(itemsData)->
    for name in itemsData.split ","
      if not @db.things.items.get name then console.error "invailid item name",name
      @items.push new PlayerItem @db,name
    if @items.length > 0
      @UI.collect.J.show()
  handleEncounteringMonster:->
    if not @monsters or @monsters.length is 0
      return false
    @place.once "battleWin",=>
      @monsters = null
      @UI.monster.J.hide()
      @UI.boss.J.hide()
    return @monsters
  active:->
    console.log "active"
    monsters = @handleEncounteringMonster()
    if monsters
      return type:"monster",monsters:monsters
    else
      item = Utils.random @items
      if item
        newArr = []
        newArr.push i for i in @items when i isnt item
        @items = newArr
        return type:"item",item:item
    @UI.collect.J.hide()
    return type:"empty"
    
class Place extends Layer
  constructor:(@area,@db,@name,@data)->
    super()
    @camera = new Camera()
    if @data.defaultX then @camera.x = @data.defaultX
    @drawQueueAddAfter @camera
    @initBg()
    @initMenu()
    @resPoints = []
    @currentX = 0
    self = this
  tick:->
    s = Utils.getSize()
    if Key.up
      if Key.shift
        @camera.scale += 0.03
        #@camera.z += 20
      #else @camera.y -= 20
    if Key.down
      if Key.shift
        @camera.scale -= 0.03
        #@camera.scale = 1 if @camera.scale < 1
        #@camera.z -= 20
      #else @camera.y += 20
    if Key.right
      @currentX += 15
      changed = true
    if Key.left
      @currentX -= 15
      changed = true
    if @currentX < 0 then @currentX = 0
    if @currentX > @mainBg.width - s.width then @currentX = @mainBg.width - s.width
    @camera.x = @camera.getOffsetPositionX @currentX,@mainBg if changed
  initBg:->
    initLayer=(layer,detail)->
      for name,value of detail
        switch name
          when "fixToBottom" then layer.fixToBottom()
          when "scale"
            console.log "scale",value
            layer.transform.scale = value
          else layer[name] = value
    @floatBgs = []
    @bgs = []
    if @data.bg then for imgName,data of @data.bg
      bg = new Layer().setImg Res.imgs[imgName]
      initLayer bg,data
      @bgs.push bg
      @camera.render bg 
    if @data.floatBg then for imgName,data of @data.floatBg
      bg = new Layer().setImg Res.imgs[imgName]
      initLayer bg,data
      @floatBgs.push bg
      @camera.render bg 
    @mainBg = @bgs[0]
  initMenu:->
    s = Utils.getSize()
    @menu = new Menu Res.tpls['area-menu']
    @menu.J.addClass @name
    @menu.UI.title.J.text @data.name
    moveCallback = ()=>
      x = @currentX
      delete @camera.lock
      if x is 0
        @menu.UI['move-left'].J.removeClass("autohide").fadeOut 200
      else
        @menu.UI['move-left'].J.addClass("autohide").fadeIn 200
      if x is (@mainBg.width - s.width)
        @menu.UI['move-right'].J.removeClass("autohide").fadeOut 200
      else
        @menu.UI['move-right'].J.addClass("autohide").fadeIn 200
    @menu.UI['move-right'].onclick = (evt)=>
      evt.stopPropagation()
      @camera.lock = true
      @currentX += 400
      #if @currentX < 0 then @currentX = 0
      if @currentX > @mainBg.width - s.width then @currentX = @mainBg.width - s.width
      x = @camera.getOffsetPositionX @currentX,@mainBg
      if x > @mainBg.width then x = @mainBg.width
      @camera.animate {x:x},"normal",->
        moveCallback()
    @menu.UI['move-left'].onclick = (evt)=>
      evt.stopPropagation()
      @camera.lock = true
      @currentX -= 400
      if @currentX < 0 then @currentX = 0
      #if @currentX > @mainBg.width - s.width then @currentX = @mainBg.width - s.width
      x = @camera.getOffsetPositionX @currentX,@mainBg
      @camera.animate {x:x},"normal",->
        moveCallback()
    @menu.UI.backpack.onclick = (evt)=>
      evt.stopPropagation()
      @emit "showBackpack"
    @menu.dom.onclick = (evt)=>
      x = evt.myOffsetX or evt.offsetX
      y = evt.myOffsetY or evt.offsetY
      @searchPosition x,y
    @relativeMenu = new Menu Res.tpls['area-relative-menu']
    @relativeMenu.J.addClass @name
    @relativeMenu.z = @mainBg.z
    @relativeMenu.UI['res-point-box'].J.hide()
    for p,index in @data.resPoints
      @addResPoint(p,index)
    for mp,index in @data.movePoints
      @addMovePoint(mp,index)
    @menu.show()
    @relativeMenu.appendTo @menu.UI['relative-wrapper']
    @camera.render @relativeMenu
  searchPosition:(x,y)->
    s = Utils.getSize()
    scale = 1.3
    if not @scaledIn
      return if @camera.lock
      @camera.lock = true
      #@menu.J.find(".autohide").addClass "invisible"
      @scaledIn = true
      @lastCameraPosition =
        x:@camera.x
        y:@camera.y
      realW = s.width/scale
      realH = s.height/scale
      dx = x - s.width/2
      dy = y - s.height/2
      wEdge = s.width/2 - realW/2
      hEdge = s.height/2 - realH/2
      if dx < - wEdge
        dx = - wEdge
      if dx > wEdge
        dx = wEdge
      if dy < - hEdge
        dy = - hEdge
      if dy > hEdge
        dy = hEdge
      realX = @currentX + dx
      realY = 0 + dy
      cx = @camera.getOffsetPositionX realX,@mainBg
      cy = @camera.getOffsetPositionY realY,@mainBg
      for bg in @floatBgs
        bg.animate {"transform.opacity":0},"fast"
      @menu.J.find(".autohide").fadeOut "fast",=>
        @relativeMenu.UI['res-point-box'].J.fadeIn "fast"
      @camera.animate {x:cx,y:cy,scale:scale},"fast",=>
        @camera.lock = false
    else
      return if @camera.lock
      @camera.lock = true
      @scaledIn = false
      for bg in @floatBgs
        bg.animate {"transform.opacity":1},"fast"
      @relativeMenu.UI['res-point-box'].J.fadeOut "fast",=>
        @menu.J.find(".autohide").fadeIn "fast"
      @camera.animate {x:@lastCameraPosition.x,y:@lastCameraPosition.y,scale:1},"fast",=>
        @camera.lock = false
  addResPoint:(p,index)->
    self = this
    point = new ResPoint this,@relativeMenu.UI['res-point-tpl'].J.html(),p,index
    point.appendTo @relativeMenu.UI['res-point-box']
    point.on "active",(res)->
      self.handleResPointActive res
  addMovePoint:(data,index)->
    point = new MovePoint this,@relativeMenu.UI['move-point-tpl'].innerHTML,data
    if @data.guardians and @data.guardians[point.moveTarget]
      point.setGuardians @data.guardians[point.moveTarget]
    point.appendTo @relativeMenu.UI['move-point-box']
  handleResPointActive:(res)->
    if res.type is "item"
      @emit "getItem",res.item
    else if res.type is "monster"
      @encounterMonster(res.monsters)
    else if res.type is "empty"
      box = new GatherResaultBox()
      box.show()
    else
      console.error "invailid res type of res point :#{res}" if GameConfig.debug
  encounterMonster:(monsters)->
    console.log "encounter monsters:",monsters
    @area.initBattlefield monsters
      
class window.Area extends Stage
  constructor:(game,areaName)->
    super game
    @game = game
    @name = areaName
    @data = game.db.areas.get areaName
    @originData = @data
    @backpackMenu = new Backpack game,"gatherArea"
    @enterPlace "entry"
    #@initBattlefield(["qq","qq"])
    #@initBattlefield(["qq","qq","qq"])
    #@initBattlefield(["qq","qq","qq","qq","qq"])
  initBattlefield:(monsters)->
    data =
      monsters:monsters
      bg:@data.battlefieldBg
    @game.saveStage()
    bf = @game.switchStage "battle",data
    bf.on "win",=>
      AudioManager.play "home"
      @game.restoreStage()
      @emit "battleWin"
      @currentPlace.emit "battleWin"
      @currentPlace.menu.show()
  enterPlace:(placeName)->
    if placeName is "exit"
      return @game.switchStage "worldMap"
    placeData = @data.places[placeName]
    console.error "no place:"+placeName if not placeData
    @currentPlace = new Place this,@game.db,placeName,placeData
    @clearDrawQueue()    
    @drawQueueAddAfter @currentPlace
    @currentPlace.on "getItem",(playerItem)=>
      @getItem playerItem
    @currentPlace.on "showBackpack",()=>
      @showBackpack()
  showBackpack:->
    console.log "show backpack"
    self = this
    @backpackMenu.on "close",->
      self.currentPlace.onShow = true
      self.backpackMenu.hide ->
        self.currentPlace.menu.show()
    @backpackMenu.show ->
      self.currentPlace.onShow = false
  getItem:(playerItem)->
    console.log playerItem
    @game.player.getItem "backpack",playerItem
    box = new GatherResaultBox playerItem
    box.show()
  tick:->
    @currentPlace.tick() if @currentPlace.tick
    
