class Place extends Layer
  constructor:(@area,@db,@name,@data)->
    super()
    @bg = new Layer Res.imgs[@data.bg]
    @menu = new Menu Res.tpls['area-menu']
    @menu.J.addClass @name
    @menu.UI.backpack.onclick = =>
      @emit "showBackpack"
    @menu.show()
    @resPoints = []
    @drawQueueAddAfter @bg
    @initItems()
    self = this
    for p,index in @data.resPoints
      item = new Suzaku.Widget @menu.UI['res-point-tpl'].J.html()
      item.J.html "采集点#{index+1}"
      item.dom.number = index+1
      item.J.addClass "gp#{index+1}"
      item.appendTo @menu.UI['res-point-box']
      item.dom.onclick = ->
        self.handleGatherResault self.gatherItem @number
    for moveTarget,index in @data.movePoints
      item = new Suzaku.Widget @menu.UI['move-point-tpl'].innerHTML
      item.J.html moveTarget
      item.dom.target = moveTarget
      item.J.addClass "mp-"+moveTarget
      item.appendTo @menu.UI['move-point-box']
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
      self.backpackMenu.hide =>
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
    

