class Place extends Layer
  constructor:(@area,@db,@name,@data)->
    super()
    @bg = new Layer Res.imgs[@data.bg]
    @menu = new Menu Res.tpls['area-menu']
    @menu.J.addClass @name
    @menu.show()
    @resPoints = []
    @drawQueueAddAfter @bg
    @initItems()
    self = this
    for p,index in @data.resPoints
      item = new Suzaku.Widget @menu.UI['res-point-tpl'].J.html()
      item.J.html index
      item.dom.number = index
      item.J.addClass "gp"+index
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
    for name,itemData in @db.things.items
      continue if not itemData.gather
      item = new GatherItem name,itemData
      gatherData = item.getGatherDataByPlace @area.name,@name
      if gatherData
        @resPoints[gatherData.resPoint - 1] = item
    console.log @resPoints
  gatherItem:(resPointNum)->
    index = resPointNum - 1
    items = @resPoints[index]
    res = []
    return "这里什么也没有" if items.length is 0
    if item.tryGather() is true
      res.push item
    return res
  handleGatherResault:(data)->
    if typeof data isnt "string"
      @emit "getItem",data
    box = new GatherResaultBox data
    box.show()
      
class GatherResaultBox extends PopupBox
  constructor:(data)->
    super()
    @UI.title.J.text "采集结果"
    if typeof data is "string"
      @UI.content.J.text data.str
      return
      
class window.Area extends Stage
  constructor:(@game,areaName)->
    super game
    @name = areaName
    @data = game.db.areas[areaName]
    @enterPlace "entry"
  enterPlace:(placeName)->
    if placeName is "exit"
      return @game.switchStage "worldMap"
    placeData = @data.places[placeName]
    console.error "no place:"+placeName if not placeData
    @currentPlace = new Place this,@game.db,placeName,placeData
    @clearDrawQueue()
    @drawQueueAddAfter @currentPlace
    

