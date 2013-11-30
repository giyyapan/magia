class SpeedItem extends Widget
  constructor:(tpl,originData)->
    super tpl
    @speedGage = 80
    @maxSpeed = 100
    @hp = 300
    @speed = originData.statusValue.spd
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
    
class SpellSourceItem extends Widget
  constructor:(tpl,type,menu,playerSupplies)->
    super tpl
    @type = type
    @playerSupplies = playerSupplies
    @originData = playerSupplies.originData
    @effectData = @originData[type]
    @traitValue = playerSupplies.traitValue
    @UI.img.src = @originData.img
    @UI.name.J.text @originData.name
    @dom.onclick = (evt)=>
      menu.detailsBox.showItemDetails this
      
class DetailsBox extends ItemDetailsBox
  constructor:(bf)->
    super
    @bf = bf
    @UI['cancel-btn'].onclick = =>
      @bf.menu.UI['spell-source-box'].J.find("li").removeClass "selected"
      @J.fadeOut 100
  showItemDetails:(item)->
    super item
    switch item.type
      when "active" then t = "激活效果:"
      when "defense" then t = "结界效果:"
    @UI['rune-type'].J.text t
    @UI.description.J.text item.effectData.description
    @UI['use-btn'].onclick = =>
      @useItem item
  useItem:(sourceItemWidget)->
    menu = @bf.menu
    menu.UI['magic-menus'].J.fadeOut 150
    if sourceItemWidget.type is "active"
      switch sourceItemWidget.effectData.type
        when "attack" or "debuff"
          menu.hideActionBtns()
          menu.showTargetSelect "magic",
            cancel:=>
              menu.showActionBtns()
              menu.UI['magic-menus'].J.fadeIn 150
            success:(target)=>@bf.player.castSpell sourceItemWidget,target
        when "areaAttack"
          @bf.player.castSpell sourceItemWidget,@bf.monsters
        when "buff","heal"
          @bf.player.castSpell sourceItemWidget,@bf.player
        else console.error "invailid item active type#{sourceItemWidget.effectData.type}"
    else
      @bf.player.castSpell sourceItemWidget,@bf.player
        
class BattlefieldPlayer extends Sprite
  constructor:(battlefield,x,y,playerData,originData)->
    super x,y,originData
    @playerData = playerData
    @statusValue = originData.statusValue
    for name,value of originData.statusValue
      this[name] = value
    @bf= battlefield
    @transform.scaleX = -1;
    @lifeBar = new Widget @bf.menu.UI['life-bar']
    @lifeBar.UI['life-text'].J.text "#{parseInt(@hp)}/#{@statusValue.hp}"
    @speedItem = battlefield.menu.addSpeedItem originData
    @speedItem.on "active",=>
      @act()
  act:->
    @bf.paused = true
    @bf.camera.lookAt this,400
    @bf.menu.showActionBtns()
  tick:(tickDelay)->
    if not @bf.paused
      @speedItem.tick tickDelay
  attack:(target)->
    @bf.paused = true
    damage = @originData.skills.attack.damage
    @bf.setView "default"
    defaultPos = x:@x,y:@y
    @useMovement "move",true
    @animateClock.setRate "fast"
    @animate {x:target.x-150,y:target.y},800,=>
      @bf.camera.lookAt target,300,2
      @animateClock.setRate "normal"
      @useMovement "attack"
      listener = @on "keyFrame",(index,length)=>
        realDamage = {}
        for name,value of damage
          realDamage[name] = (value / length)
        realDamage.normal = 600
        target.onAttack this,realDamage
      @once "endMove:attack",=>
        @bf.setView "normal"
        @bf.camera.unfollow()
        @off "keyFrame",listener
        @transform.scaleX = 1
        @animateClock.setRate "fast"
        @useMovement "move",true
        @animate {x:defaultPos.x,y:defaultPos.y},800,=>
          @animateClock.setRate "normal"
          @transform.scaleX = -1
          @useMovement @defaultMovement,true
          @bf.paused = false
  defense:->
  castSpell:(sourceItemWidget,target)->
    console.log "cast spell to ",target
    sourceItemWidget.playerSupplies.remainCount -= 1
    if sourceItemWidget.playerSupplies.remainCount < 0
      @playerData.removeThing playerSupplies
    callback = =>
      @bf.setView "normal"
      @bf.paused = false
    if sourceItemWidget.type is "active"
      switch sourceItemWidget.effectData.type
        when "attack" then target.onAttack this,sourceItemWidget.effectData.damage
        when "heal" then target.onHeal sourceItemWidget.effectData.heal
        when "buff" then target.onBuff sourceItemWidget.effectData.buff
    else
      target.addFlipOverEffect sourceItemWidget.effectData
    callback()
  addFlipOverEffect:(effect)->
  onBuff:(effect)->
  onHeal:(value)->
    @hp += value
    if @hp > @statusValue.hp
      @hp = @statusValue.hp
    @updateLifeBar "heal"
  onAttack:(from,damage)->
    #console.log "player onattack,damage:",damage
    @bf.camera.shake "fast"
    for type,value of damage
      @hp -= value
    if @hp <= 0
      @hp = 0
      @updateLifeBar()
      @die()
    else
      @updateLifeBar()
  updateLifeBar:(type="damage")->
    J = @lifeBar.UI['life-inner'].J
    if type is "damage"
      J.addClass "damage"
      @setCallback 100,=>
        J.removeClass("damage")
    J.css "width","#{parseInt(@hp/@statusValue.hp*100)}%"
    @lifeBar.UI['life-text'].J.text "#{parseInt(@hp)}/#{@statusValue.hp}"
  draw:(context,tickDelay)->
    super context,tickDelay
    context.fillRect(-10,-10,20,20);
  die:->
    return if @dead
    @dead = true
    @bf.lose()
    
class MonsterLifeBar extends Drawable
  constructor:(monster)->
    width = 150
    super 0,-130,150,10
    @monster = monster
    @value = @monster.hp
  draw:(context)->
    percent = (@value/@monster.maxHp)
    Utils.drawRoundRect context,-@width/2,-@height/2,parseInt(percent * @width),@height,4,0,0,4
    if percent > 0.75
      context.fillStyle = "green"
    else if percent > 0.3
      context.fillStyle = "orange"
    else
      context.fillStyle = "red"
    context.fill()
    Utils.drawRoundRect context,-@width/2,-@height/2,@width,@height,4
    context.strokeStyle = "white"
    context.lineWidth = 2
    context.stroke()
    
class BattlefieldMonster extends Sprite
  constructor:(battlefield,x,y,originData)->
    super x,y,originData
    @bf = battlefield
    @statusValue = originData.statusValue
    @originData = originData
    @name = originData.name
    for name,value of originData.statusValue
      this[name] = value
    @maxHp = @statusValue.hp
    @lifeBar = new MonsterLifeBar this
    @drawQueueAddAfter @lifeBar
    @speedItem = battlefield.menu.addSpeedItem originData
    @speedItem.on "active",=>
      @attack @bf.player
  tick:(tickDelay)->
    if not @bf.paused and not @dead
      @speedItem.tick tickDelay
  attack:(target)->
    @bf.paused = true
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
        @lifeBar.transform.scaleX = -1
        @animateClock.setRate "fast"
        @useMovement "move",true
        @animate {x:defaultPos.x,y:defaultPos.y},800,=>
          @animateClock.setRate "normal"
          @transform.scaleX = 1
          @lifeBar.transform.scaleX = 1
          @useMovement @defaultMovement,true
          @bf.paused = false
  onAttack:(from,damage)->
    @bf.camera.shake "fast"
    for name,value of damage
      @hp -= value
    if @hp <= 0
      @lifeBar.animate value:0,100,"swing"
      @die()
      return
    @lifeBar.animate value:@hp,100,"swing"
  draw:(context,tickDelay)->
    super context,tickDelay
    context.fillRect(-10,-10,20,20);
  die:->
    return if @dead
    @dead = true
    @animateClock.paused = true
    @speedItem.remove()
    @fadeOut 1000,=>
      @bf.mainLayer.drawQueueRemove this
      newArr = []
      for m in @bf.monsters when m isnt this
        newArr.push m
      @bf.monsters = newArr
      if @bf.monsters.length is 0
        @bf.win()
    
class BattlefieldMenu extends Menu
  constructor:(battlefield,tpl)->
    super tpl
    @bf = battlefield
    @detailsBox = new DetailsBox @bf
    @detailsBox.appendTo @UI['item-details-box-wrapper']
    @initBtns()
  initBtns:->
    @UI['attack-btn'].onclick = (evt)=>
      @handlePlayerAttack()
    @UI['defense-btn'].onclick = (evt)=>
      @handlePlayerDefense()
    @UI['magic-btn'].onclick = (evt)=>
      @handlePlayerMagic()
    @UI['escape-btn'].onclick = (evt)=>
      @handlePlayerEscape()
    @UI['active-rune'].onclick = (evt)=>
      @UI['active-rune'].J.addClass "selected"
      @showSpellSourceLayer "active"
    @UI['defense-rune'].onclick = (evt)=>
      @UI['defense-rune'].J.addClass "selected"
      @showSpellSourceLayer "defense"
    stopPropagation = (evt)-> evt.stopPropagation()
    @UI['spell-select-box'].onclick = stopPropagation
    @UI['spell-source-box'].onclick = stopPropagation
    @detailsBox.onclick = stopPropagation
  addSpeedItem:(originData)->
    tpl = @UI['speed-item-tpl'].innerHTML
    item = new SpeedItem tpl,originData
    item.appendTo @UI['speed-item-list']
    return item
  showActionBtns:(callback)->
    @UI['action-btns'].J.addClass("show")
    @UI['status-box'].J.addClass("show")
    callback() if callback
  hideActionBtns:(callback)->
    @UI['action-btns'].J.removeClass("show")
    @UI['status-box'].J.removeClass("show")
    callback() if callback
  handlePlayerAttack:->
    console.log "attack clicked"
    @hideActionBtns()
    @bf.setView "default"
    @showTargetSelect "attack",
      success:(target)=>@bf.player.attack(target)
      cancel:(target)=>@bf.player.act()
  showTargetSelect:(type,callbacks)->
    @bf.setView "default"
    @UI['target-select-box'].J.html ''
    @UI['target-select-layer'].J.fadeIn 150
    @UI['target-select-layer'].onclick = =>
      @UI['target-select-layer'].J.fadeOut 150
      callbacks.cancel() if callbacks.cancel
    switch type
      when "attack" then tpl = @UI['attack-target-btn-tpl'].innerHTML
      when "magic" then tpl = @UI['magic-target-btn-tpl'].innerHTML
    self = this
    for target in @bf.monsters
      item = new Widget tpl
      item.dom.target = target
      item.J.css
        top:"#{target.y - 100}px"
        left:"#{target.x - 200}px"
      item.dom.onclick = (evt)->
        evt.stopPropagation()
        self.UI['target-select-layer'].J.fadeOut 150
        callbacks.success(@target) 
      item.appendTo @UI['target-select-box']
  handlePlayerDefense:->
    console.log "defense clicked"
  handlePlayerMagic:->
    @UI['spell-source-layer'].J.hide()
    @detailsBox.J.hide()
    @UI['spell-select-layer'].J.hide()
    @UI['spell-select-layer'].J.find("li").removeClass "selected"
    @UI['magic-menus'].J.show()
    @UI['spell-select-layer'].J.fadeIn 150
    @UI['spell-select-layer'].dom.onclick = =>
      @UI['spell-select-layer'].J.fadeOut 150
  handlePlayerEscape:->
    console.log "escape"
    @bf.lose()
  showSpellSourceLayer:(type)->
    switch type
      when "active" then @UI["spell-source-type"].innerHTML = "激活符文"
      when "defense" then @UI["spell-source-type"].innerHTML = "结界符文"
      else return console.error "invailid type:#{type}"
    self = this
    tpl = @UI['item-tpl'].innerHTML
    @UI['spell-source-list'].J.html ""
    for i in @bf.player.playerData.backpack
      if not i.originData[type] then continue
      item = new SpellSourceItem tpl,type,this,i
      item.appendTo @UI['spell-source-list']
    @UI['spell-source-layer'].J.fadeIn 150
    @UI['spell-source-layer'].dom.onclick = =>
      @UI['spell-select-box'].J.find("li").removeClass "selected"
      @UI['spell-source-layer'].J.fadeOut 150
    
class window.Battlefield extends Stage
  constructor:(game,data)->
    super game
    @game = game
    @data = data
    @db = game.db
    @camera = new Camera()
    @drawQueueAddAfter @camera
    @paused = false
    @initLayers()
    @initSprites()
    @setView "default"
  initSprites:->
    s = Utils.getSize()
    baseY = parseInt(s.height/2 + 30)
    @player = new BattlefieldPlayer this,300,baseY,@game.player,@db.monsters.get("qq")
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
          when "anchor" then bg.setAnchor value
          else bg[name] = value
      @camera.render bg
    @mainLayer = @bgs[0] if not @mainLayer
    @camera.defaultReferenceZ = @mainLayer.z
    @menu = new BattlefieldMenu this,Res.tpls['battlefield-menu']
    @drawQueueAddAfter @menu
  win:->
    monsters = []
    @emit "win",monsters:@data.monsters
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
