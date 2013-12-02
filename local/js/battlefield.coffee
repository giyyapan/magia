class window.BlendLayer extends Drawable
  constructor:(host,color)->
    super 0,0,host.width,host.height
    @host = host
    @anchor = host.anchor
    @color = color
    @thirdCanvas = Utils.getTempCanvas 3
    @thirdContext = @thirdCanvas.getContext "2d"
    @host.drawQueueAdd this
  draw:(realContext)->
    context = @thirdContext
    x = Math.floor -@host.anchor.x >> 0
    y = Math.floor -@host.anchor.y >> 0
    w = Math.floor @host.width >> 0
    h = Math.floor @host.height >> 0
    s = Utils.getSize()
    context.save()
    context.translate s.width/2,s.height/2
    context.clearRect x,y,w,h
    @host.draw context
    #context.globalCompositeOperation = "source-atop"
    context.globalCompositeOperation = "source-in"
    context.fillStyle = @color
    context.fillRect x,y,w,h
    context.restore()
    realContext.drawImage @thirdCanvas,s.width/2+x,s.height/2+y,w,h,x,y,w,h
    
class window.SpeedItem extends Widget
  constructor:(tpl,data)->
    super tpl
    @speedGage = 50
    @maxSpeed = 100
    @speed = data.statusValue.spd
    console.log data
    @UI.icon.src = data.icon.src if data.icon
  tick:(tickDelay)->
    @speedGage += tickDelay/1000*@speed
    if @speedGage > @maxSpeed
      @setWidgetPosition @maxSpeed
      @speedGage = 0
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
    w = sourceItemWidget
    if w.type is "active"
      switch w.effectData.type
        when "attack","debuff","dot"
          menu.hideActionBtns()
          menu.showTargetSelect "magic",
            cancel:=>
              menu.showActionBtns()
              menu.UI['magic-menus'].J.fadeIn 150
            success:(target)=>@bf.player.useSpell w.type,w.playerSupplies,target
        else
          @bf.player.useSpell w.type,w.playerSupplies,@bf.player
    else
      @bf.player.useSpell w.type,w.playerSupplies,@bf.player
        
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
      item.UI.name.J.text target.name
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
    box = new PopupBox "逃跑","逃跑会返回家里。</br> 要逃跑么？",=>
      @bf.lose()
    box.setAcceptText "逃跑"
    box.setCloseText "不要"
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
  displaySpellName:->
    return true
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
    @tick = ->
    @menu.J.fadeOut "fast"
    text = ""
    wraper = "<span class='center'>{}</span>"
    dropMoney = 0
    for m in @monsters
      for name,value of m.drop
        switch name
          when "money" then dropMoney += value
    @game.player.money += value
    text = wraper.replace "{}","获得金钱:#{value}G"
    @game.player.saveData()
    box = new MsgBox "胜利","战斗胜利！</br>#{text}"
    box.on "close",=>
      @emit "win",monsters:@data.monsters
    console.log "win!!!"
  lose:->
    @menu.J.fadeOut "fast"
    @mainLayer.fadeOut "normal"
    @tick = ->
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
