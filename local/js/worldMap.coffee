class MapPoint extends Widget
  constructor:(tpl,data)->
    super tpl
    @UI["map-summary-name"].innerHTML = data.name
    

class window.WorldMap extends Stage
  constructor:(game)->
    super()
    @game = game
    map = new Layer()
    @player = @game.player
    @db = @game.db
    
    forestData = @db.areas.get "forest"
    forestData.description

    @menu = new Menu Res.tpls['world-map']
    for name in ["forest","snowmountain"]
      data = @db.areas.get name
      imgName = data.summaryImg
      img = window.Res.imgs[imgName]
      console.log @UI
      newItem = new MapPoint @menu.UI['map-point-tpl'].innerHTML,data
      newItem.appendTo @menu.UI['map-summary-holder']

    map.setImg Res.imgs.worldMap
    console.log @menu
    @menu.show()
    @drawQueueAddAfter map,@menu
    @menu.UI.home.onclick = ->
      game.switchStage "home"
    @menu.UI.town.onclick = ->
      game.switchStage "town"
    @menu.UI.forest.onclick = ->
      game.switchStage "area","forest"
    @menu.UI.snowmountain.onclick = ->
      game.switchStage "area","snowmountain"

    
