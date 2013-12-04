class window.SpeedItem extends Widget
  constructor:(tpl,host)->
    super tpl
    @speedGage = 50
    @maxSpeed = 100
    @host = host
    @UI.icon.src = host.icon.src if @host.icon
  tick:(tickDelay)->
    @speed = @host.realStatusValue.spd
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
    if w.type is "defense"
      @bf.player.useSpell w.type,w.playerSupplies,@bf.player
    else
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
  addSpeedItem:(bfSprite)->
    tpl = @UI['speed-item-tpl'].innerHTML
    item = new SpeedItem tpl,bfSprite
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
      @UI['spell-select-layer'].J.fadeOut 150,=>
        @detailsBox.J.hide()
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
      @UI['spell-source-layer'].J.fadeOut 150,=>
        @detailsBox.J.hide()
    
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
      @bgs.push bg
    @mainLayer = @bgs[0] if not @mainLayer
    @camera.defaultReferenceZ = @mainLayer.z
    @menu = new BattlefieldMenu this,Res.tpls['battlefield-menu']
    @drawQueueAddAfter @menu
  win:->
    AudioManager.mute()
    @tick = ->
    @menu.J.fadeOut "fast"
    text = ""
    wraper = "<span class='center'>{}</span>"
    money = 0
    for mname in @data.monsters
      mdata = @db.monsters.get mname
      for name,value of mdata.drop
        switch name
          when "money" then money += parseInt(value)
    @game.player.money += money
    text = wraper.replace "{}","获得金钱:#{money}G"
    @game.player.saveData()
    box = new MsgBox "胜利","战斗胜利！</br>#{text}"
    box.on "close",=>
      @emit "win",monsters:@data.monsters
    console.log "win!!!"
  lose:->
    AudioManager.mute()
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
