class PlayerAttackAffect extends Drawable
  constructor:(x,y)->
    super x,y
    @z = 999
    @radius = 25
  draw:(context)->
    context.fillStyle = "rgba(79, 175, 212, 0.75)"
    context.beginPath()
    context.arc(0,0,@radius,0,Math.PI*2,true)
    context.closePath()
    context.fill()

class window.BattlefieldPlayer extends BattlefieldSprite
  constructor:(battlefield,x,y,playerData)->
    @db = battlefield.db
    super battlefield,x,y,@db.sprites.get "player"
    console.log this
    @playerData = playerData
    @statusValue = playerData.statusValue
    @name = "player"
    for name,value of playerData.statusValue
      this[name] = value
    #@hp = 30
    @bf = battlefield
    @lifeBar = new Widget @bf.menu.UI['life-bar']
    @lifeBar.UI['life-text'].J.text "#{parseInt(@hp)}/#{@statusValue.hp}"
    @speedItem = battlefield.menu.addSpeedItem this
    @speedItem.on "active",=>
      @act()
  act:->
    @emit "act"
    @bf.paused = true
    @bf.camera.lookAt {x:@x + 100,y:@y - 150},400,1.7
    @bf.menu.showActionBtns()
  attack:(target)->
    @bf.paused = true
    @z = 10
    @bf.mainLayer.sortDrawQueue()
    @bf.setView "default"
    defaultPos = x:@x,y:@y
    @animateClock.setRate 10
    @useMovement "attack"
    listener = @on "keyFrame",(index,length)=>
      @attackFire target
    @once "endMove:attack",=>
      @off "keyFrame",listener
      @z = -1
      @bf.mainLayer.sortDrawQueue()
      @useMovement @defaultMovement,true
  attackFire:(target)->
    blendLayer = new BlendLayer this,"rgba(79, 175, 212, 0.81)"
    blendLayer.flash 150,=>
      @drawQueueRemove blendLayer
    damage = @handleAttackDamage normal:@playerData.statusValue.atk
    window.AudioManager.play "playerCast"
    effect = new PlayerAttackAffect @x + 100,@y - 100
    @bf.mainLayer.drawQueueAdd effect
    effect.animate x:target.x,y:target.y,300,=>
      effect.animate {"radius":250,"transform.opacity":0.2},150,=>
        @bf.mainLayer.drawQueueRemove effect
      target.onHurt this,damage
      @bf.paused = false
  defense:->
    @isDefensed = true
    bl = new BlendLayer this,"rgba(238, 215, 167, 0.4)"
    @once "act",=>
      @isDefensed = false
      @drawQueueRemove bl
    @bf.paused = false
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
        when "attack" then target.onHurt this,sourceItemWidget.effectData.damage
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
  onHurt:(from,damage)->
    if @isDefensed
      for type,value of damage
        damage[type] = parseInt(value/3)
    super
    if @hp <= 1 and @bf.data.nolose
      @hp = 1
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
    #context.fillRect(-10,-10,20,20);
  die:->
    return if @dead
    @dead = true
    @bf.lose()

  
