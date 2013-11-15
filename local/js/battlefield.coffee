class SpeedItem extends Suzaku.Widget
  constructor:(tpl,originData)->
    super tpl
    @speedGage = 80
    @maxSpeed = 100
    @hp = 300
    @speed = originData.basicData.spd
    #@icon = originData.icon
  tick:(tickDelay)->
    @speedGage += tickDelay/1000*@speed
    if @speedGage > @maxSpeed
      @setWidgetPosition @maxSpeed
      @speedGage -= @maxSpeed
      @emit "active"
    else
      @setWidgetPosition @speedGage
  setWidgetPosition:(value)->
    @J.css "left",parseInt(value/@maxSpeed*100)+"%"
    
class BattlefieldPlayer extends Sprite
  constructor:(battlefield,x,y,originData)->
    super x,y,originData
    @basicData = originData.basicData
    for name,value of originData.basicData
      this[name] = value
    @bf= battlefield
    @transform.scaleX = -1;
    @lifeBar = new Widget @bf.menu.UI['life-bar']
    @speedItem = battlefield.menu.addSpeedItem originData
    @speedItem.on "active",=>
      @act()
  act:->
    @bf.isPaused = true
    @bf.camera.lookAt this,@bf.mainLayer.z,180,=>
      @bf.menu.playerAct()      
  tick:(tickDelay)->
    if not @bf.isPaused
      @speedItem.tick tickDelay
  attack:(target)->
    @bf.isPaused = true
    @bf.camera.follow this,@bf.mainLayer.z
    damage = @originData.skills.attack.damage
    defaultPos = x:@x,y:@y
    @useMovement "move",true
    @animateClock.setRate "fast"
    @animate {x:target.x-150,y:target.y},800,=>
      @animateClock.setRate "normal"
      @useMovement "attack"
      listener = @on "keyFrame",(index,length)=>
        realDamage = {}
        for name,value of damage
          realDamage[name] = (value / length)
        target.onAttack this,realDamage
      @once "endMove:attack",=>
        @off "keyFrame",listener
        @transform.scaleX = 1
        @animateClock.setRate "fast"
        @useMovement "move",true
        @animate {x:defaultPos.x,y:defaultPos.y},800,=>
          @animateClock.setRate "normal"
          @transform.scaleX = -1
          @useMovement @defaultMovement,true
          @bf.camera.unfollow()
          @bf.setView "default"
          @bf.isPaused = false
  defense:->
  castSpell:->
  onAttack:(from,damage)->
    #console.log "player onattack,damage:",damage
    @bf.camera.shake "fast"
    for type,value of damage
      @hp -= value
    @lifeBar.UI['life-inner'].J.css "width","#{parseInt(@hp)}%"
    @lifeBar.UI['life-text'].J.text "#{parseInt(@hp)}/#{@basicData.hp}"
  draw:(context,tickDelay)->
    super context,tickDelay
    context.fillRect(-10,-10,20,20);
    
class BattlefieldMonster extends Sprite
  constructor:(battlefield,x,y,originData)->
    super x,y,originData
    @basicData = originData.basicData
    for name,value of originData.basicData
      this[name] = value
    @bf = battlefield
    @speedItem = battlefield.menu.addSpeedItem originData
    @speedItem.on "active",=>
      @attack @bf.player
  tick:(tickDelay)->
    if not @bf.isPaused
      @speedItem.tick tickDelay
  attack:(target)->
    @bf.isPaused = true
    damage = @originData.skills.attack.damage
    defaultPos = x:@x,y:@y
    @useMovement "move",true
    @animateClock.setRate "fast"
    @animate {x:target.x+150,y:target.y},800,=>
      @animateClock.setRate "normal"
      @useMovement "attack"
      listener = @on "keyFrame",(index,length)=>
        realDamage = {}
        for name,value of damage
          realDamage[name] = (value / length)
        target.onAttack this,realDamage
      @once "endMove:attack",=>
        @off "keyFrame",listener
        @transform.scaleX = -1
        @animateClock.setRate "fast"
        @useMovement "move",true
        @animate {x:defaultPos.x,y:defaultPos.y},800,=>
          @animateClock.setRate "normal"
          @transform.scaleX = 1
          @useMovement @defaultMovement,true
          @bf.isPaused = false
  onAttack:(from,target)->
  draw:(context,tickDelay)->
    super context,tickDelay
    context.fillRect(-10,-10,20,20);
    
class BattlefieldMenu extends Menu
  constructor:(battlefield,tpl)->
    super tpl
    @bf = battlefield
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
  addSpeedItem:(originData)->
    tpl = @UI['speed-item-tpl'].innerHTML
    item = new SpeedItem tpl,originData
    item.appendTo @UI['speed-item-list']
    return item
  playerAct:(callback)->
    @UI['action-box'].J.fadeIn "fast",callback
  hideActionBox:(callback)->
    @UI['action-box'].J.fadeOut "fast",callback
  handlePlayerAttack:->
    console.log "attack clicked"
    @hideActionBox()
    @bf.player.attack(@bf.monsters[0])
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
    @isPaused = false
    @initLayers()
    @initSprites()
    @setView "default"
  initSprites:->
    s = Utils.getSize()
    baseY = parseInt(s.height/2 + 30)
    @player = new BattlefieldPlayer this,300,baseY,@db.monsters.get("qq")
    @mainLayer.drawQueueAddAfter @player
    @monsters = []
    startX = 1000
    dx = 50
    dy = 100
    startY = parseInt(baseY - (@data.monsters.length-1) * (dy*0.5))
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
        switch name
          when "main" then @mainLayer = bg
          when "fixToBottom" then bg.fixToBottom()
          else bg[name] = value
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
  tick:(tickDelay)->
    @player.tick(tickDelay)
    monster.tick(tickDelay) for monster in @monsters
  setView:(name,callback)->
    switch name
      when "default","normal"
        @camera.animate {x:0,y:0,scale:1},200,callback
