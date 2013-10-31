class window.WorldMap extends Stage
  constructor:(game)->
    super()
    @game = game
    map = new Layer()
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
    
