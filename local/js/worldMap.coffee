class MapPoint extends Widget
  constructor:(tpl,data)->
    super tpl
    @UI.name.innerHTML = data.name
    @UI.description.innerHTML = data.description
    

class window.WorldMap extends Stage
  constructor:(game)->
    super()
    @game = game
    map = new Layer()
    @player = @game.player
    @db = @game.db
    
    forestData = @db.areas.get "forest"
    forestData.description

    for name in ["forest","snowmountain"]
      data = @db.areas.get name
      imgName = data.summaryImg
      img = window.Res.imgs[imgName]
      newItem = new MapPoint @UI['map-point-tpl'].innerHTML,data
      newItem.appendTo @UI['map-point-box']

    map.setImg Res.imgs.worldMap
    @menu = new Menu Res.tpls['world-map']
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

    
