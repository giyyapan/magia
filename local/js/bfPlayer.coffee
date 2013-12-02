class window.BattlefieldPlayer extends BattlefieldSprite
  constructor:(battlefield,x,y,playerData)->
    @db = battlefield.db
    @playerData = playerData
    super battlefield,x,y,@db.sprites.get("player"),playerData
    @castPositionX = 100
    @castPositionY = -100
    console.log this
    @animateClock.setRate 10
    @name = "player"
    for name,value of playerData.statusValue
      this[name] = value
    #@hp = 30
    @bf = battlefield
    @lifeBar = new Widget @bf.menu.UI['life-bar']
    @lifeBar.UI['life-text'].J.text "#{parseInt(@hp)}/#{@statusValue.hp}"
  act:->
    super
    @bf.camera.lookAt {x:@x + 100,y:@y - 150},400,1.7
    @bf.menu.showActionBtns()
  attack:(target)->
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
    effect = new BfEffectSprite @bf,@db.sprites.get("energyBall"),this,target
    effect.on "active",=>
      target.onHurt this,damage
      @bf.paused = false
  defense:->
    @isDefensed = true
    bl = new BlendLayer this,"rgba(238, 215, 167, 0.4)"
    @speedItem.speedGage += 30
    @once "act",=>
      @isDefensed = false
      @drawQueueRemove bl
    @bf.paused = false
  useSpell:(type,sourceSupplies,target)->
    console.log "cast spell to ",target
    @bf.setView "normal"
    @useMovement "attack"
    @once "keyFrame",=>
      window.AudioManager.play "playerCast"
      super type,sourceSupplies,target
    sourceSupplies.remainCount -= 1
    if sourceSupplies.remainCount < 0
      @playerData.removeThing sourceSupplies
  addFlipOverEffect:(effect)->
  onBuff:(effect)->
  onHeal:(from,value)->
    super
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

  
