class DamageText extends Drawable
  constructor:(host,type,value,startY=0)->
    super 0,0
    value = parseInt(value)
    switch type
      when "miss"
        @color = "white"
        @value = "未命中"
      when "normal"
        @color = "rgb(255,150,80)"
        @value = "- #{value} 通常伤害"
      when "fire"
        @color = "#99130E"
        @value = "- #{value} 火焰伤害"
      when "ice"
        @color = "#4AAAB8"
        @value = "- #{value} 冰霜伤害"
      when "impact"
        @color = "#9C7013"
        @value = "- #{value} 冲击伤害"
      when "minus"
        @color = "#444CA2"
        @value = "- #{value} 负能量伤害"
      when "spirit"
        @color = "#912CB1"
        @value = "- #{value} 灵能伤害"
      when "heal"
        @color = "#59a84c"
        @value = "+ #{value} 生命回复"
    @y = - host.height + host.anchor.y + 50 + startY
    @host = host
    @transform.scale = 1
    @transform.opacity = 0
    @host.drawQueueAdd this
    @animate {y:"-=150","transform.opacity":1},"fast",=>
      @fadeOut "slow",=>
        @host.drawQueueRemove this
  onDraw:->
    if @host.transform.scaleX < 0 then @transform.scaleX = -1
    else @transform.scaleX = 1
    super
  draw:(context)->
    context.font = 'bold 38px sans-serif';
    context.fillStyle = "black"
    context.fillText @value,-100,0
    context.fillStyle = @color
    context.fillText @value,-100,1

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
    
class StatusMark extends Drawable
  constructor:(status)->
    @status = status
    @host = status.host
    @name = status.spellData.name
    width = 120
    height = 35
    counter = 0
    for type,obj of @host.status
      for name,status of obj
        counter += 1
    dy = counter * height + 5
    switch status.spellData.type
      when "buff","hot","heal"
        @color = "#59a84c"
        @textColor = "black"
      else
        @color = "#555"
        @textColor = "white"
    if @host.name is "player"
      x = 150
      y = -200 + dy
    else
      x = -150
      y = -100 + dy
    super x,y,width,height
    @transform.opacity = 0.6
    @textX = -38
    @textY = 5
  draw:(context)->
    #console.log "status mark draw"
    context.fillStyle = @color
    context.beginPath()
    Utils.drawRoundRect context,-@width/2,-@height/2,@width,@height,5
    context.closePath()
    context.fill()
    context.font = "bold 18px sans-serif"
    context.fillStyle = @textColor
    remainTurn = @status.turn - @status.counter
    context.fillText "#{@name} #{remainTurn}",@textX,@textY
    
class Status extends EventEmitter
  constructor:(host,sourceSupplies,spellData)->
    super
    @sourceSupplies = sourceSupplies
    @traitValue = @sourceSupplies.traitValue
    @traitValueLevel = @sourceSupplies.traitValueLevel
    @spellData = spellData
    @counter = 0
    @name = spellData.name
    @host = host
    @turn = Math.round(@getRealValue(spellData.turn)) or 5
    @listeners = []
    @initMark()
    @addHostListener "act",=>
      @nextTurn()
  initMark:->
    @statusMark = new StatusMark this
    @host.drawQueueAdd @statusMark
  nextTurn:->
    @counter += 1
    if @counter >= @turn
      console.log "remove status"
      @remove()
  remove:->
    console.log "status  #{@name} removed"
    @host.removeStatus this
    @host.drawQueueRemove @statusMark
    for l in @listeners
      @host.off l.event,l.f
    @host = null
  getRealValue:(value)->
    if not value then return false
    if value not instanceof Array then return value
    max = value[1]
    min = value[0]
    return min + (@traitValueLevel/6)*(max - min)
  addHostListener:(event,func)->
    @host.on event,func
    @listeners.push
      event:event
      func:func

class FlipOverEffect extends Status
  remove:->
    super
    delete @host.flipOverEffects[@name]
    
class Dot extends Status
  constructor:(host,sourceSupplies,spellData)->
    super
    @rate = spellData.rate or 1
    @damage = {}
    console.log spellData.damage
    for type,value of spellData.damage
      @damage[type] = value * @traitValue * @rate
    console.log @damage
    @addHostListener "act",=>
      console.log "fuck"
      @active()
  active:->
    @host.onHurt null,@damage
    
class Hot extends Status
  constructor:(host,sourceSupplies,spellData)->
    super
    @rate = spellData or 1
    @heal = data.heal * @traitValue * @rate
    @addHostListener "act",=>
      @active()
  active:->
    @host.onHeal @heal

class EffectStatus extends Status
  constructor:(host,sourceSupplies,spellData)->
    #on "updateStatusValue",on "damage", on "heal" on "hurt"
    super
    console.log "fuck fuck fuck"
    console.log spellData
    if spellData.effect
      console.log "enter"
      @addHostListener "updateStatusValue",(statusValue)=>
        @onEffect statusValue
      console.log @host
  onEffect:(statusValue)->
    console.log "on effect fire"
    for type,value of @spellData.effect
      if not statusValue[type]
        switch type
          when "accuracy" then statusValue[type] = 95
          when "resistance" then statusValue[type] = 10
          when "iceDef","fireDef","impactDef","spiritDef","minusDef"
            statusValue[type] = 10
      value = @getRealValue(value)
      statusValue[type] *= value
    return statusValue

class Buff extends EffectStatus
        
class Debuff extends EffectStatus
    
class window.BfEffectSprite extends Sprite
  constructor:(bf,spriteData,from,to)->
    super 0,0,spriteData
    @transform.scale = 1.3
    @z = 999
    @host = null
    if @movements.fly
      @x = from.x + (from.castPositionX or 0)
      @y = from.y + (from.castPositionY or 0)
      @host = bf
      @useMovement "fly",true
      @animate x:to.x + 50,y:to.y + 100,"normal",=>
        @emit "active"
        @animate {"transform.scale":2},"fast"
        @useMovement "active",=>
          @destroy()
    else
      @x = 0
      @y = 0
      @host = to
      @useMovement "active",=>
        console.log "movement end"
        @emit "active"
        @destroy()
      @on "keyFrame",=>
        @emit "active"
    @host.drawQueueAdd this
  destroy:->
    super
    @host.drawQueueRemove this
  draw:->
    super
          
class window.BattlefieldSprite extends Sprite
  constructor:(bf,x,y,spriteData,originData)->
    super x,y,spriteData
    @originData = originData
    @statusValue = @originData.statusValue
    @realStatusValue = Utils.clone @statusValue
    @shadow = new Shadow this,@spriteData.shadowRadius
    @drawQueueAddBefore @shadow
    @bf = bf
    @hp = @realStatusValue.hp
    @icon = spriteData.icon
    @status = 
      buffs:{}
      debuffs:{}
      dots:{}
      hots:{}
      flipOver:{}
    @dead = false
    @speedItem = bf.menu.addSpeedItem this
    @speedItem.on "active",=>
      @act()
  updateStatusValue:->
    @realStatusValue = Utils.clone @statusValue
    @emit "updateStatusValue",@realStatusValue
    console.log "update status value",@realStatusValue
  act:->
    @bf.paused = true
    @updateStatusValue()
    console.log "act",this
    @emit "act",@realStatusValue
  handleFlipOverEffectes:(damage,from)->
    for name,data of @status.flipOver
      switch data.spellData.type
        when "buff","heal","hot"
          target = this
        else
          target = from
      @castSpell data.sourceSupplies,data.spellData,target
  handleAttackDamage:(damage)->
    accuracy = @realStatusValue.accuracy or 80
    if Math.random()*100 > accuracy
      for type,value of damage
        delete damage[type]
      console.log "击空"
    else
      @emit "damage",damage
      console.log "攻击"
    return damage
  handleHurtDamage:(damage)->
    statusValue = @realStatusValue
    miss = statusValue.miss or 5
    if Math.random()*100 < miss
      console.log "未闪避"
      for type,value of damage
        delete damage[type]
      return damage
    console.log "闪避",damage
    @emit "hurt",damage,statusValue
    if @isDefensed
      def = statusValue.def * 2
    else
      def = statusValue.def
    for type,value of damage
      if type is "normal"
        damage[type] -= def
      else
        damage[type] -= def/2
      defName = "#{type}Def"
      if statusValue[defName]
        value -= statusValue[defName]
      if damage[type] <= 0 then damage[type] = 1
    return damage
  defense:->
    @bf.paused = false
  attackFire:(target,index,length)->
  attack:->
  useSpell:(activeType,sourceSupplies,target)->
    # activeType:active,defense
    name = sourceSupplies.name
    originData = sourceSupplies.originData
    if not originData[activeType] then return console.error "no #{activeType} data in supplies",sourceSupplies
    spellData = originData[activeType]
    if spellData.sameWithActive
      rate = spellData.rate or 0.3
      name = spellData.name
      spellData = originData.active
      spellData.rate = rate
      spellData.name = name
    if activeType is "defense"
      @addStatus "flipOver",new FlipOverEffect this,sourceSupplies,spellData
      spriteData = @db.sprites.effects.get "buff"
      effect = new BfEffectSprite @bf,spriteData,this,target
      effect.once "active",=>
        @defense()
    else
      @castSpell sourceSupplies,spellData,target,=>
        @bf.paused = false
        @bf.menu.hideActionBtns()
  getSpellDamage:(sourceSupplies,spellData)->
    if not spellData.damage then return console.error "no damage data in spelldata",spellData
    damage = {}
    damageRate = spellData.damage
    globalRate = spellData.rate or 1
    for type,rate of damageRate
      damage[type] = sourceSupplies.traitValue * rate * globalRate
    console.log "spell damage",damageRate,damage
    return damage
  getSpellHeal:(sourceSupplies,spellData)->
    if not spellData.heal then return console.error "no heal data in spelldata",spellData
    globalRate = spellData.rate or 1
    healRate = spellData.heal * globalRate
    return healRate * sourceSupplies.traitValue
  castSpell:(sourceSupplies,spellData,target,callback)->
    console.log "castSpell",arguments
    name = spellData.name
    @bf.displaySpellName spellData.name
    self = this
    switch spellData.type
      when "attack"
        sprite = spellData.sprite or "energyBall"
        damage = @getSpellDamage sourceSupplies,spellData
        @emit "damage",damage
        f = ->
          target.onHurt self,damage
      when "heal"
        sprite = spellData.sprite or "buff"
        heal = @getSpellHeal sourceSupplies,spellData
        @emit "heal",heal
        f = ->
          target.onHeal self,heal
      when "dot"
        sprite = spellData.sprite or "debuff"
        f = ->
          target.addStatus "dot",new Dot target,sourceSupplies,spellData
      when "hot"
        sprite = spellData.sprite or "buff"
        f = ->
          target.addStatus "hot",new Hot target,sourceSupplies,spellData
      when "buff"
        sprite = spellData.sprite or "buff"
        f = ->
          console.log "active"
          target.addStatus "buff",new Buff target,sourceSupplies,spellData
          target.updateStatusValue()
      when "debuff"
        sprite = spellData.sprite or "debuff"
        f = ->
          target.addStatus "debuff",new Debuff target,sourceSupplies,spellData
          target.updateStatusValue()
    spriteData = @db.sprites.effects.get sprite
    spellData.spriteData = spriteData
    effect = new BfEffectSprite @bf,spriteData,this,target
    effect.once "active",=>
      f()
      callback() if callback
    if spellData.next
      @castSpell sourceSupplies,spellData.next,target,callback
    else
  onHeal:(from,heal)->
    @hp += heal
    new BlendLayer this,"rgba(180,250,200,0.6)","flash","fast"
    new DamageText this,"heal",heal
  onHurt:(from,damage)->
    console.log "#{@name} on hurt",damage
    @bf.camera.shake "fast"
    window.AudioManager.play "hurt"
    @handleFlipOverEffectes damage,from if from
    damage = @handleHurtDamage damage
    idx = 0
    for type,value of damage
      if not value then continue
      text = new DamageText this,type,value,(50*idx+1)
      @hp -= value
      idx += 1
    if idx is 0
      new DamageText this,"miss"
    else
      if @isDefensed
        effect = new BlendLayer this,"rgba(238, 215, 167, 0.6)","flash","fast"
      else
        effect = new BlendLayer this,"rgba(240,30,30,0.8)","flash","fast"
  addStatus:(type,status)->
    switch type
      when "buff" then type = "buffs"
      when "debuff" then type = "debuffs"
      when "dot" then type = "dots"
      when "hot" then type = "hots"
      when "flipOver" then type = "flipOver"
    if @status[type][status.name] then @status[type][status.name].remove()
    @status[type][status.name] = status
  removeStatus:(targetStatus)->
    for type,obj of @status
      for name,status of obj
        if status is targetStatus
          delete obj[name]
          return true
    return false
  die:->
    for type,obj of @status
      for name,status of obj
        status.remove()
  draw:(context)->
    super
    #context.fillRect -10,-10,10,10
  tick:(tickDelay)->
    if not @bf.paused and not @dead
      @speedItem.tick tickDelay

