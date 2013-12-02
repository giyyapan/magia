class DamageText extends Drawable
  constructor:(host,type,value)->
    super 0,0
    @value = "-#{value}"
    switch type
      when "normal" then @color = "rgb(235, 88, 88)"
      when "heal"
        @color = "green"
        @value = "+#{value}"
    @y = - host.height + host.anchor.y + 50
    @host = host
    @transform.scale = 1
    @transform.opacity = 0
    @host.drawQueueAdd this
    @animate {y:"-=150","transform.opacity":1},"fast",=>
      @fadeOut "normal",=>
        @host.drawQueueRemove this
  draw:(context)->
    context.font = 'bold 40pt Calibri';
    context.fillStyle = @color
    context.fillText @value,30,-10

class Shadow extends Drawable
  constructor:(host,radius)->
    super 0,110
    @host = host
    @host.drawQueueAddBefore this
    @radius = radius or 70
  draw:(context)->
    context.scale(1, 0.35);
    context.fillStyle = "rgba(20,20,20,0.2)"
    context.beginPath()
    context.arc(0,0,@radius,0,Math.PI*2,true)
    context.closePath()
    context.fill()
    
class Status extends EventEmitter
  constructor:(host,data)->
    super
    @couter = 0
    @host = host
    @turn = data.turn or 3
  nextTurn:->
    @couter += 1
    if @couter > @turn then @remove()
  remove:->
    @host.removeStatus this
    @host = null
      
class Buff extends Status
  constructor:(data)->
    super
  handleAttackDamage:(damage)->
    return damage
  handleOnAttacakDamage:(damage)->
    return damage

class Debuff extends Status
  constructor:(data)->
    super
  handleAttackDamage:(damage)->
    return damage
  handleOnAttacakDamage:(damage)->
    return damage
    
class Dot extends Status
  constructor:(data)->
    super
  active:->
    
class Hot extends Status
  constructor:(data)->
    super
  active:->
    
class window.BfEffectSprite extends Sprite
  constructor:(bf,spriteData,from,to)->
    super 0,0,spriteData
    @transform.scale = 1.3
    @z = 999
    if @movements.fly
      @x = from.x + (from.castPositionX or 0)
      @y = from.y + (from.castPositionY or 0)
      bf.drawQueueAdd this
      @useMovement "fly",true
      @animate x:to.x + 50,y:to.y + 100,"normal",=>
        @emit "active"
        @animate {"transform.scale":2},"fast"
        @useMovement "active",=>
          @destroy()
          bf.drawQueueRemove this
    else
      @x = 0
      @y = 0
      to.drawQueueAdd this
      @useMovement "active",=>
        console.log "movement end"
        @emit "destroy"
        to.drawQueueRemove this
        if not @destroyed
          @emit "active"
          @destroy()
      @on "keyFrame",=>
        @emit "active"
        @destroy()
  draw:->
    super
          
class window.BattlefieldSprite extends Sprite
  constructor:(bf,x,y,spriteData,originData)->
    super x,y,spriteData
    @originData = originData
    @statusValue = @originData.statusValue
    @shadow = new Shadow this,@spriteData.shadowRadius
    @drawQueueAddBefore @shadow
    @bf = bf
    @hp = null
    @icon = spriteData.icon
    @status = 
      buffs:{}
      debuffs:{}
      dots:{}
      hots:{}
    @flipOverEffects = {}
    @dead = false
    @speedItem = bf.menu.addSpeedItem this
    @speedItem.on "active",=>
      @act()
  act:->
    @bf.paused = true
    @emit "act"
    for type,obj of @status
      for name,status of obj
        status.nextTurn()
  handleAttackDamage:(damage)->
    for name,buff of @status.buffs
      buff.handleAttackDamage damage
    for name,debuff of @status.debuffs
      debuff.handleAttackDamage damage
    return damage
  handleHurtDamage:(damage)->
    for name,buff of @status.buffs
      buff.handleAttackDamage damage
    for name,debuff of @status.debuffs
      debuff.handleAttackDamage damage
    return damage
  handleHealQuantity:(heal)->
    return heal
  attackFire:(target,index,length)->
  useSpell:(activeType,sourceSupplies,target,callback)->
    # activeType:active,defense
    name = sourceSupplies.name
    originData = sourceSupplies.originData
    if not originData[activeType] then return console.error "no #{activeType} data in supplies",sourceSupplies
    spellData = originData[activeType]
    if spellData.sameWithActive
      rate = spellData.rate or 0.3
      spellData = originData.active
      spellData.rate = rate
    if activeType is "defense"
      @isDefensed = true
      @flipOverEffects[name] = spellData
      callback() if callback
    else
      @castSpell sourceSupplies,spellData,target,callback
  getSpellDamage:(sourceSupplies,spellData)->
    if not spellData.damage then return console.error "no damage data in spelldata",spellData
    damage = {}
    damageRate = spellData.damage
    for type,rate of damageRate
      damage[type] = sourceSupplies.traitValue * rate
    console.log "spell damage",damageRate,damage
    return damage
  getSpellHeal:(sourceSupplies,spellData)->
    if not spellData.heal then return console.error "no heal data in spelldata",spellData
    healRate = spellData.heal
    return healRate * sourceSupplies.traitValue
  castSpell:(sourceSupplies,spellData,target,callback)->
    name = spellData.name
    @bf.displaySpellName spellData.name
    self = this
    switch spellData.type
      when "attack"
        sprite = spellData.sprite or "energyBall"
        damage = @handleAttackDamage @getSpellDamage sourceSupplies,spellData
        f = ->
          target.onHurt self,damage
      when "heal"
        sprite = spellData.sprite or "buff"
        heal = @handleHealQuantity @getSpellHeal sourceSupplies,spellData
        f = ->
          target.onHeal self,heal
      when "dot"
        sprite = spellData.sprite or "debuff"
        f = ->
          target.status.dots[name] = new Dot this,spellData
      when "hot"
        sprite = spellData.sprite or "buff"
        f = ->
          target.status.hots[name] = new Hot this,spellData
      when "buff"
        sprite = spellData.sprite or "buff"
        f = ->
          target.status.buffs[name] = new Buff this,spellData
      when "debuff"
        sprite = spellData.sprite or "debuff"
        f = ->
          target.status.debuffs[name] = new Debuff this,spellData
    spriteData = @db.sprites.effects.get sprite
    effect = new BfEffectSprite @bf,spriteData,this,target
    effect.on "destroy",=>
      @bf.paused = false
      callback() if callback
    effect.on "active",f
  onHeal:(from,heal)->
    @hp += heal
  onHurt:(from,damage)->
    console.log "#{name} on attack",damage
    @bf.camera.shake "fast"
    window.AudioManager.play "hurt"
    if @isDefensed
      effect = new BlendLayer this,"rgba(238, 215, 167, 0.6)"
    else
      effect = new BlendLayer this,"rgba(240,30,30,0.8)"
    effect.transform.opacity = 1
    effect.flash 150,=>
      @drawQueueRemove effect
    @handleHurtDamage damage
    for type,value of damage
      new DamageText this,type,value
      @hp -= value
  removeStatus:(targetStatus)->
    for type,obj of @status
      for name,status of obj
        if status is targetStatus
          delete obj[name]
          return true
    return false
  draw:(context)->
    super
    #context.fillRect -10,-10,10,10
  tick:(tickDelay)->
    if not @bf.paused and not @dead
      @speedItem.tick tickDelay

