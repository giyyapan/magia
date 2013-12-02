class window.MonsterLifeBar extends Drawable
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
    
class window.BattlefieldMonster extends BattlefieldSprite
  constructor:(battlefield,x,y,name)->
    console.log name
    @bf = battlefield
    @db = @bf.db
    @originData = @db.monsters.get name
    spriteOriginData = @db.sprites.get(@originData.sprite)
    super battlefield,x,y,spriteOriginData
    if @originData.scale then @transform.scale = @originData.scale;
    @name = @originData.name
    @statusValue = @originData.statusValue
    @maxHp = @statusValue.hp
    @hp = @maxHp
    @lifeBar = new MonsterLifeBar this
    @drawQueueAddAfter @lifeBar
    @speedItem = battlefield.menu.addSpeedItem this
    @speedItem.on "active",=>
      @emit "act"
      @attack @bf.player 
  attack:(target)->
    @bf.paused = true
    defaultPos = x:@x,y:@y
    @useMovement "move",true
    @animateClock.setRate "fast"
    @animate {x:target.x+150,y:target.y},800,=>
      @animateClock.setRate "normal"
      @useMovement "attack"
      listener = @on "keyFrame",(index,length)=>
        @attackFire target,index,length
      @once "endMove:attack",=>
        @off "keyFrame",listener
        scale =  @transform.scale
        @transform.scaleX = - scale
        @lifeBar.transform.scaleX = - scale
        @animateClock.setRate "fast"
        @useMovement "move",true
        @animate {x:defaultPos.x,y:defaultPos.y},800,=>
          @animateClock.setRate "normal"
          @transform.scaleX = scale
          @lifeBar.transform.scaleX = scale
          @useMovement @defaultMovement,true
          @bf.paused = false
  attackFire:(target,index,length)->
    sound = @originData.attackSound or "qqHit"
    window.AudioManager.play sound
    damage = @handleAttackDamage @originData.damage
    realDamage = {}
    for name,value of damage
      realDamage[name] = (value / length)
    target.onHurt this,realDamage
  onHurt:(from,damage)->
    super
    if @hp <= 0
      @lifeBar.animate value:0,100,"swing"
      @die()
      return
    @lifeBar.animate value:@hp,100,"swing"
  draw:(context,tickDelay)->
    super context,tickDelay
    #context.fillRect(-10,-10,20,20);
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
