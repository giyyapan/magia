class window.BattlefieldAffect extends Drawable
  constructor:(x,y)->
    super x,y
  draw:(context)->
    context.fillStyle = "rgba(255,255,255,0.5)"
    context.beginPath()
    context.arc(0,0,25,0,Math.PI*2,true)
    context.closePath()
    context.fill()

class Buff extends EventEmitter
  constructor:(data)->
    super null
  handleAttackDamage:(damage)->
  handleOnAttacakDamage:(damage)->

class Debuff extends EventEmitter
  constructor:(data)->
    super null
  handleAttackDamage:(damage)->
  handleOnAttacakDamage:(damage)->
    
class Dot extends EventEmitter
  constructor:(data)->
    super null
  handleAttackDamage:(damage)->
  handleOnAttacakDamage:(damage)->

      
class window.BattlefieldSprite extends Sprite
  constructor:(x,y,spriteData)->
    super 
    @icon = spriteData.icon
    @buffs = {}
    @debuffs = {}
    @dots = {}
    @dead = false
  handleAttackDamage:(damage)->
    for name,buff of @buffs
      buff.handleAttackDamage damage
    for name,debuff of @debuffs
      debuff.handleAttackDamage damage
    return damage
  handleOnAttacakDamage:(damage)->
    for name,buff of @buffs
      buff.handleAttackDamage damage
    for name,debuff of @debuffs
      debuff.handleAttackDamage damage
    return damage
  addStatus:(type,data)->
    #buff debuff dot
    switch type
      when "buff" then
      when "debuff" then
      when "dot" then
    return status
  clearStatus:(status)->
    return true
  draw:(context)->
    super
    #context.fillRect -10,-10,10,10
  tick:(tickDelay)->
    if not @bf.paused and not @dead
      @speedItem.tick tickDelay

class window.SpeedItem extends Widget
  constructor:(tpl,data)->
    super tpl
    @speedGage = 80
    @maxSpeed = 100
    @speed = data.statusValue.spd
    console.log data
    @UI.icon.src = data.icon.src if data.icon
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
    
class SpellSourceItem extends ListItem
  constructor:(tpl,type,menu,playerSupplies)->
    super tpl,playerSupplies
    @type = type
    @effectData = @originData[type]
    @traitValue = playerSupplies.traitValue
    @UI.img.src = playerSupplies.img.src
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
    @hideActionBtns()
    @bf.setView "default"
    @bf.player.defense()
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
    if @bf.data.story
      new MsgBox "提示","剧情战斗不能逃走！请直面人生吧～"
      return
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
    @player = new BattlefieldPlayer this,150,baseY,@game.player
    @mainLayer.drawQueueAddAfter @player
    @monsters = []
    startX = 1000
    dx = 50
    dy = 100
    startY = parseInt(baseY - (@data.monsters.length-1) * (dy*0.5))
    for name,index in @data.monsters
      x = startX + index*dx
      y = startY + index*dy
      monster = new BattlefieldMonster this,x,y,name
      monster.z = index
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
      console.log "fuck",bg
      @bgs.push bg
    console.log @bgs
    @mainLayer = @bgs[0] if not @mainLayer
    @camera.defaultReferenceZ = @mainLayer.z
    @menu = new BattlefieldMenu this,Res.tpls['battlefield-menu']
    @drawQueueAddAfter @menu
  win:->
    @paused = true
    monsters = []
    box = new MsgBox "胜利","战斗胜利！"
    box.on "close",=>
      @emit "win",monsters:@data.monsters
    console.log "win!!!"
  lose:->
    @paused = true
    evt = {}
    @emit "lose",evt
    if not evt.handled
      box = new MsgBox "战斗失败","战斗失败，自动返回家里"
      box.on "close",=>
        @game.switchStage "home"
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
