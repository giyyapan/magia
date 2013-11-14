class BattlefieldPlayer extends Sprite
  constructor:(battlefield,x,y,originData)->
    super x,y,originData
    @battlefield = battlefield
    @transform.scaleX = -1;
  attack:->
  defense:->
  castSpell:->
  onattack:->
    
class BattlefieldMonster extends Sprite
  constructor:(battlefield,x,y,originData)->
    super x,y,originData
    @battlefield = battlefield
  draw:(context)->
    #console.log "enter"
    super context
  attack:->
  onattack:->
    
class BattlefieldMenu extends Menu
  constructor:(battlefield,tpl)->
    super tpl
    @battlefield = battlefield
    @initBtns()
  initBtns:->
    @UI['attack-btn'].onclick = (evt)=>
      evt.stopPropagation()
      @handlePlayerAttack()
    @UI['defense-btn'].onclick = (evt)=>
      evt.stopPropagation()
      @handlePlayerDefense()
    @UI['magic-btn'].onclick = (evt)=>
      evt.stopPropagation()
      @handlePlayerMagic()
    @UI['escape-btn'].onclick = (evt)=>
      evt.stopPropagation()
      @handlePlayerEscape()
  handlePlayerAttack:->
    console.log "attack clicked"
  handlePlayerDefense:->
    console.log "defense clicked"
  handlePlayerMagic:->
    console.log "magic clicked"
  handlePlayerEscape:->
    console.log "escape clicked"
    
class window.Battlefield extends Stage
  constructor:(game,data)->
    super game
    @game = game
    @data = data
    @db = game.db
    @camera = new Camera()
    @drawQueueAddAfter @camera
    @initLayers()
    @initSprites()
    @setView "default"
  initSprites:->
    startY = 400
    dy = 100
    @player = new BattlefieldPlayer this,200,startY,@db.monsters.get("qq")
    @mainLayer.drawQueueAddAfter @player
    @monsters = []
    startX = 1000
    dx = 50
    for name,index in @data.monsters
      x = startX + index*dx
      y = startY + index*dy
      mdata = @db.monsters.get name
      monster = new BattlefieldMonster this,x,y,mdata
      @monsters.push monster
      @mainLayer.drawQueueAddAfter monster
  initLayers:->
    @bgs = []
    @mainLayer = null
    for imgName,detail of @data.bg
      img = Res.imgs[imgName]
      bg = new Layer().setImg img
      for name,value of detail
        if name is "main" then @mainLayer = bg
        if name is "fixToBottom"
          bg.fixToBottom()
        else
          bg[name] = value
      @camera.render bg
    @mainLayer = @bgs[0] if not @mainLayer
    @menu = new BattlefieldMenu this,Res.tpls['battlefield-menu']
    @drawQueueAddAfter @menu
  win:->
    @emit "win"
    console.log "win!!!"
  lose:->
    @emit "lose"
    console.log "lose!!!"
  show:->
    super =>
      @menu.show()
  tick:(delayTime)->
  setView:(name)->
  
