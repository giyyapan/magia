testData =
  monsters:["qq"]
  
class widnow.Battlefield extends Stage
  constructor:(game,data)->
    super game
    data = testData
    @game = game
    @camera = new Camera()
    @drawQueueAddAfter @camera
    @player = new BattlefieldPlayer
    @monsters = []
    for monsters in data
      @monsters.push new Battlefield
    @initLayers()
    @initMenus()
    @setView "default"
  initLayers:->
    @mainLayer = new Layer Res.imgs.bfForestMain
    mainBg.z = 100
    @floatLayer = new Layer Res.imgs.bfForestFloat
    floatBg.z = 1
    @camera.render @mainLayer,@floatLayer
  initMenus:->
    @menu = new Menu Res.tpls['battlefield-menu']
    @drawQueueAddAfter @menu
  initSprites:->
  setView:(name)->
  
