class GatherResultItem extends Widget
  constructor:(originData,number)->
    super Res.tpls['thing-list-item']
    @UI.img.src = originData.img.src if originData.img
    @UI.name.J.text originData.name
    @UI.quatity.J.text number
    @originData = originData
    
class GatherResaultBox extends PopupBox
  constructor:(data)->
    super()
    @UI.title.J.text "采集结果"
    if typeof data is "string"
      @UI.content.J.text data
    else
      @UI.content.J.hide()
      @UI['content-list'].J.show()
      for itemResData in data
        originData = itemResData.gatherItem.originData
        number = itemResData.number
        console.log itemResData
        w = new GatherResultItem originData,number
        w.appendTo @UI['content-list']

class ResPoint extends Suzaku.Widget
  constructor:(place,tpl,data,index)->
    super tpl
    @place = place
    @data = data
    @index = index
    @number = index + 1
    @pointText = "采集点#{index+1}"
    @items = []
    @monsters =
      certain:null #certain 只能有一种情况
      random:[]
    @UI.name.J.text @pointText
    @dom.number = index+1
    @J.addClass "gp#{index+1}"
    @J.css left:data.split(",")[0]+"px",top:data.split(",")[1]+"px",
    @dom.onclick = (evt)=>
      evt.stopPropagation()
      @emit "active",@active()
  initItems:(resourcesData,db)->
    return if not resourcesData[@index]
    for name in resourcesData[@index].split ","
      itemData = db.things.items.get name
      console.log itemData
      item = new GatherItem name,itemData
      gatherData = item.getGatherData()
      @items.push item
  initMonsters:(monstersData,db)->
    for mdata in monstersData.random
      if Utils.compare mdata.split(":")[0],@number
        @monsters.random.push mdata.split(":")[1]
    if @monsters.random.length > 0
      @UI.name.J.text @pointText + "（可）"
    for mdata in monstersData.certain
      if Utils.compare mdata.split(":")[0],@number
        @monsters.certain =  mdata.split(":")[1]
        @UI.name.J.text @pointText + "（必）"
  handleEncounteringMonster:->
    if @monsters.certain
      @place.once "battleWin",=>
        @monsters.certain = null
      return @monsters.certain.split(",")
    for m,index in @monsters.random
      if Math.random() < 0.3
        @randomMonsterIndex = index
        @place.once "battleWin",=>
          Utils.removeItemByIndex @monsters.random,@randomMonsterIndex
          delete @randomMonsterIndex
        return m.split(",")
    return false
  active:->
    console.log "active"
    monsters = @handleEncounteringMonster()
    if monsters
      return type:"monster",monsters:monsters
    else
      items = []
      for item in @items
        gatherNumber = item.tryGather()
        if gatherNumber
          items.push gatherItem:item,number:gatherNumber
      return type:"item",items:items
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
        if name is "fixToBottom"
          layer.fixToBottom()
        else
          layer[name] = value
    @floatBgs = []
    @bgs = []
    if @data.bg then for imgName,data of @data.bg
      bg = new Layer().setImg Res.imgs[imgName]
      console.log bg,data
      initLayer bg,data
      @bgs.push bg
      @camera.render bg 
    if @data.floatBg then for imgName,data of @data.floatBg
      bg = new Layer().setImg Res.imgs[imgName]
      console.log bg,data
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
      console.log "right"
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
      console.log "left"
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
      @searchPosition evt.offsetX,evt.offsetY
    @relativeMenu = new Menu Res.tpls['area-relative-menu']
    @relativeMenu.J.addClass @name
    @relativeMenu.z = 1000
    @relativeMenu.UI['res-point-box'].J.hide()
    for p,index in @data.resPoints
      @addResPoint(p,index)
    for moveTarget,index in @data.movePoints
      @addMovePoint(moveTarget,index)
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
    if @data.resources then point.initItems @data.resources,@db
    if @data.monsters then point.initMonsters @data.monsters,@db
  addMovePoint:(moveTarget,index)->
    area = @area
    item = new Suzaku.Widget @relativeMenu.UI['move-point-tpl'].innerHTML
    if moveTarget is "exit"
      item.UI.target.J.text "离开"
    else
      item.UI.target.J.text @area.originData.places[moveTarget].name
    item.dom.target = moveTarget
    item.J.addClass "mp-"+moveTarget
    item.appendTo @relativeMenu.UI['move-point-box']
    item.dom.onclick = ->
      area.enterPlace @target
  handleResPointActive:(res)->
    if res.type is "item"
      @emit "getItem",res.items
    else if res.type is "monster"
      @encounterMonster(res.monsters)
    else if res.type is "empty"
      box = new GatherResaultBox "什么也没有采集到"
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
    console.log bf
    bf.on "win",=>
      console.log "fuck win"
      @game.restoreStage()
      @emit "battleWin"
      @currentPlace.emit "battleWin"
      @currentPlace.menu.show()
    bf.on "lose",=>
      @game.restoreStage()
      @emit "battleLose"
      @currentPlace.emit "battleLose"
      @currentPlace.menu.show()
  enterPlace:(placeName)->
    if placeName is "exit"
      return @game.switchStage "worldMap"
    placeData = @data.places[placeName]
    console.error "no place:"+placeName if not placeData
    @currentPlace = new Place this,@game.db,placeName,placeData
    @clearDrawQueue()    
    @drawQueueAddAfter @currentPlace
    @currentPlace.on "getItem",(itemDataArr)=>
      @getItem itemDataArr
    @currentPlace.on "showBackpack",()=>
      @showBackpack()
  showBackpack:->
    console.log "show backpack"
    console.log @backpackMenu
    self = this
    @backpackMenu.on "close",->
      self.currentPlace.onShow = true
      self.backpackMenu.hide ->
        self.currentPlace.menu.show()
    @backpackMenu.show ->
      self.currentPlace.onShow = false
  getItem:(itemDataArr)->
    return if not @game.player.checkFreeSpace "backpack",itemDataArr
    for data in itemDataArr
      name = data.gatherItem.name
      originData = data.gatherItem.originData
      number = data.number
      @game.player.getItem "backpack",name:name,originData:originData,number:number
    box = new GatherResaultBox itemDataArr
    box.show()
  tick:->
    @currentPlace.tick() if @currentPlace.tick
    
