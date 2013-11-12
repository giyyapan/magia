class Place extends Layer
  constructor:(@area,@db,@name,@data)->
    super()
    @camera = new Camera()
    @drawQueueAddAfter @camera
    @initBg()
    @initMenu()
    @resPoints = []
    @currentX = 0
    @initItems()
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
    if Key.right then @currentX += 15
    if Key.left then @currentX -= 15
    if @currentX < 0 then @currentX = 0
    if @currentX > @bg.width - s.width then @currentX = @bg.width - s.width
    @camera.x = @camera.getOffsetPositionX @currentX,@bg
  initBg:->
    @bg = new Layer Res.imgs[@data.bg[0]]
    @bgFloat = new Layer Res.imgs[@data.bg[1]]
    @bgFloat2 = new Layer Res.imgs[@data.bg[2]]
    @bgFloat2.fixToBottom()
    @bgFloat2.transform.scale = 1.5
    @bgFloat2.x = 300
    @bg.z = 1000
    @bgFloat.z = 600
    @camera.render @bg,@bgFloat,@bgFloat2
  initMenu:->
    s = Utils.getSize()
    @menu = new Menu Res.tpls['area-menu']
    @menu.J.addClass @name
    @menu.UI.title.J.text @data.name
    moveCallback = ()=>
      x = @currentX
      delete @camera.lock
      if x is 0 then @menu.UI['move-left'].J.fadeOut 200
      else @menu.UI['move-left'].J.fadeIn 200
      if x is (@bg.width - s.width) then @menu.UI['move-right'].J.fadeOut 200
      else @menu.UI['move-right'].J.fadeIn 200
    @menu.UI['move-right'].onclick = (evt)=>
      evt.stopPropagation()
      console.log "right"
      @camera.lock = true
      @currentX += 400
      #if @currentX < 0 then @currentX = 0
      if @currentX > @bg.width - s.width then @currentX = @bg.width - s.width
      x = @camera.getOffsetPositionX @currentX,@bg
      if x > @bg.width then x = @bg.width
      @camera.animate {x:x},"normal",->
        moveCallback()
    @menu.UI['move-left'].onclick = (evt)=>
      evt.stopPropagation()
      console.log "left"
      @camera.lock = true
      @currentX -= 400
      if @currentX < 0 then @currentX = 0
      #if @currentX > @bg.width - s.width then @currentX = @bg.width - s.width
      x = @camera.getOffsetPositionX @currentX,@bg
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
    scale = 1.5
    return
    if not @scaledIn
      @menu.J.find(".autohide").addClass "invisible"
      @scaledIn = true
      @lastCameraPosition =
        x:@camera.x
        y:@camera.y
      realW = s.width / scale
      realH = s.height / scale
      sx = @camera.getOffsetScaleX(@bg.z)
      sy = @camera.getOffsetScaleY(@bg.z)
      dx = x + @camera.x - s.width/2
      dy = y + @camera.y - s.height/2
      realX = dx/(realW/4)/sx
      if realX < -1 then realX = -1
      if realX > 1 then realX = 1
      realX = realX*(realW/4)
      realY = @camera.y
      console.log realX,realY
      @camera.moveTo realX,realY,"fast"
      @camera.scaleTo scale,"fast"
      @bgFloat.animate {"transform.opacity":0},"fast"
    else
      @menu.J.find(".autohide").removeClass "invisible"
      @scaledIn = false
      @camera.moveTo @lastCameraPosition.x,@lastCameraPosition.y,"fast"
      @camera.scaleTo 1,"fast"
      @bgFloat.animate {"transform.opacity":1},"fast"
  addResPoint:(p,index)->
    self = this
    item = new Suzaku.Widget @relativeMenu.UI['res-point-tpl'].J.html()
    item.UI.name.J.text "采集点#{index+1}"
    item.dom.number = index+1
    item.J.addClass "gp#{index+1}"
    item.appendTo @relativeMenu.UI['res-point-box']
    item.dom.onclick = ->
      self.handleGatherResault self.gatherItem @number
  addMovePoint:(moveTarget,index)->
    area = @area
    item = new Suzaku.Widget @relativeMenu.UI['move-point-tpl'].innerHTML
    item.UI.target.J.text moveTarget
    item.dom.target = moveTarget
    item.J.addClass "mp-"+moveTarget
    item.appendTo @relativeMenu.UI['move-point-box']
    item.dom.onclick = ->
      area.enterPlace @target
  initItems:->
    for i,index in @data.resPoints
      @resPoints.push []
    for name,itemData of @db.things.items
      continue if not itemData.gather
      item = new GatherItem name,itemData
      gatherData = item.getGatherDataByPlace @area.name,@name
      if gatherData
        @resPoints[gatherData.resPoint-1].push item
    console.log @resPoints
  gatherItem:(resPointNum)->
    index = resPointNum - 1
    items = @resPoints[index]
    res = []
    return null if items.length is 0
    for item in items
      gatherNumber = item.tryGather()
      if gatherNumber
        res.push gatherItem:item,number:gatherNumber
    return res
  handleGatherResault:(data)->
    if typeof data isnt "string"
      @emit "getItem",data
    else
      box = new GatherResaultBox "什么也没有采集到"
      box.show()

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
        w = new ThingListWidget originData,number
        w.appendTo @UI['content-list']
      
class window.Area extends Stage
  constructor:(game,areaName)->
    super game
    @game = game
    @name = areaName
    @data = game.db.areas[areaName]
    @backpackMenu = new Backpack game,"gatherArea"
    @enterPlace "entry"
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
    

