class ReactionFinishBox extends PopupBox
  constructor:(@reactionBox,@db)->
    title = "装瓶"
    hint = "请选择要保留的属性</br><small>有一些中间属性无法被制作成药剂</small>"
    super title,hint
    @UI['content-list'].J.show()
    @UI['accept'].J.hide()
    self = this
    for name,i of @reactionBox.traitsItems
      if not @db.things.supplies.get "#{i.traitsName}Potion"
        console.log "no potion for traits#{i.traitsName}"
        continue
      item = new TraitsItem(i.traitsName,i.traitsValue)
      console.log "finish add traits",item
      item.appendTo @UI['content-list']
      item.onclick = ->
        self.chooseTraitsItem this
    @show()
  chooseTraitsItem:(item)->
    name = "#{item.traitsName}Potion"
    originData = @db.things.supplies.get name
    newSupplies = new PlayerSupplies name,originData,item.traitsValue
    @close()
    @emit "getNewSupplies",newSupplies
    @close()
    
class ReactionTraitsItem extends TraitsItem
  constructor:->
    super
    @J.addClass "animate-popup"
    
class ReactionConfirmBox extends PopupBox
  constructor:(reaction)->
    super "合成新属性"
    str = ""
    for name of reaction.from
      str += "<span class='traits-icon #{name}'>#{Dict.TraitsName[name]}</span>"
    targetStr = "<span class=traits-icon '#{name}'>#{Dict.TraitsName[reaction.to]}</span>"
    s =  "要将#{str}转化成为#{targetStr}吗？"
    @UI.content.J.html s
    @UI.close.J.text "取消"
    @show()
    
class ReactionBtn extends Widget
  constructor:(tpl,reaction,avail,reactionBox)->
    super tpl
    @reactionBox = reactionBox
    @worktable = reactionBox.worktable
    @avail = avail
    @reaction = reaction
    index = 0
    for name,value of reaction.from
      index += 1
      span = @UI["source#{index}"]
      span.J.addClass name
      span.J.text Dict.TraitsName[name].split("")[0]
    @update avail
    @J.removeClass "hide"
    @J.addClass "animate-popup"
    @dom.onclick = => 
      return if not @avail
      @reactionBox.react @reaction,=>
        @J.addClass("animate-popout")
        @remove()
  remove:->
    layer = @worktable
    scale = 0
    layer.animate ((p)=>
      s = scale * (1-p)
      Utils.setCSS3Attr this,"animate","scale(#{s},#{s})"
      ),1000,=>
        delete @reactionBox.reactionBtns[@reaction.to]
        super
  update:(avail)->
    @avail = avail
    if @avail
      span = @UI.target
      span.J.show()
      span.J.removeClass()
      span.J.addClass "target",@reaction.to
      span.J.text Dict.TraitsName[@reaction.to].split("")[0]
      @UI["?"].J.hide()
      @J.addClass "avail"
    else
      @J.removeClass "avail"
      @UI.target.J.hide()
      @UI["?"].J.show()
      
class ReactionBox extends Widget
  constructor:(tpl,menu)->
    super tpl
    @menu = menu
    @worktable = menu.worktable
    @traitsItems = {}
    @reactions = []
    @reactionBtns = {}
    @initReactions()
    @UI['finish'].onclick = =>
      box = new ReactionFinishBox this,@worktable.game.db
      box.on "getNewSupplies",(s)=>
        for n,i of @traitsItems
          i.remove()
        @traitsItems = {}
        new MsgBox "获得物品","你获得了#{s.dspName}！"
        @worktable.game.player.getSupplies s
    console.log @reactions
  initReactions:->
    for r in @worktable.db.rules.get "reaction"
      fromTraitsArr = r.split("->")[0].split(",")
      obj =
        from:{}
        fromTraitsNumber:fromTraitsArr.length
        to:r.split("->")[1]
      for traits in fromTraitsArr 
        t = traits.split(":")
        obj.from[t[0]] = parseInt t[1]
      @reactions.push obj
  putInItem:(playerItem)->
    for name,value of playerItem.traits
      if not @traitsItems[name]
        @traitsItems[name] = new ReactionTraitsItem(name,value).insertTo @UI['current-traits-list']
      else
        i = @traitsItems[name]
        old = i.traitsValue
        console.log i
        i.changeValue parseInt(value*value/(old+value) + old)
    @tryReaction()
  tryReaction:->
    for r in @reactions
      avail = 0 #0:not avail 1:not enough 2:avail
      for name,lvValue of r.from
        if not @traitsItems[name]
          avail = 0
          break
        if @traitsItems[name].lv >= lvValue
          if avail is 0 then avail = 2
        else
          avail = 1
      switch avail
        when 0 then continue
        when 1 then @addReactionBtn r,false
        when 2 then @addReactionBtn r,true
  addReactionBtn:(r,avail)->
    console.log r,avail
    if @reactionBtns[r.to]
      @reactionBtns[r.to].update(avail)
    else
      tpl = @UI["reaction-btn-tpl-#{r.fromTraitsNumber}"].innerHTML
      btn = new ReactionBtn tpl,r,avail,this
      btn.appendTo @UI['avail-reaction-list']
      @reactionBtns[r.to] = btn
  react:(reaction,callback)->
    console.log "react",reaction
    value = 0
    for name of reaction.from
      value += parseInt @traitsItems[name].traitsValue
    box = new ReactionConfirmBox reaction
    box.on "accept",=>
      value = value/reaction.fromTraitsNumber
      callback() if callback
      newTraits = {}
      newTraits[reaction.to] = value
      @combineTraitsItems(reaction,newTraits)
  combineTraitsItems:(reaction,newTraits)->
    self = this
    items = []
    items.push @traitsItems[name] for name of reaction.from
    for i,index in items
      targetTop = @UI['traits-box'].offsetTop
      i.dom.traitsName = i.traitsName
      i.J.addClass "animate-popout"
    @putInItem traits:newTraits
    window.setTimeout (->
      for i in items
        i.J.animate {width:0,margin:0},200,->
          $(this).remove()
          delete self.traitsItems[this.traitsName]
      ),400
      
class DetailsBox extends ItemDetailsBox
  constructor:(menu)->
    super
    @menu = menu
    @worktable= menu.worktable
    @locked = false
    @UI['use-btn'].J.html "添加"
    @UI['use-btn'].onclick = =>
      return if @locked
      @worktable.putInItem @currentItem if @currentItem
    @UI['header-flag'].J.remove()
    @UI['cancel-btn'].onclick = =>
      @menu.UI['source-list'].J.find("li").removeClass "selected"
      @J.fadeOut 100
    
class SourceItem extends Widget
  constructor:(tpl,menu,playerItem)->
    super tpl
    @originData = playerItem.originData
    @playerItem = playerItem
    @UI.img.src = @originData.img if @UI.img
    @UI.name.J.text @originData.name
    @UI.number.J.text playerItem.number if playerItem.number
    @dom.onclick = (evt)=>
      menu.detailsBox.showItemDetails this
  update:->
    @UI.number.J.text @playerItem.number if @playerItem.number
    
class WorktableMenu extends Menu
  constructor:(tpl,worktable)->
    super tpl
    @worktable = worktable
    @player = worktable.player
    @detailsBox = new DetailsBox this
    @detailsBox.appendTo @UI['item-details-box-wrapper']
    @reactionBox = new ReactionBox @UI['reaction-box'],this
    @initItems()
    @UI['exit-btn'].onclick = =>
      @worktable.close()
  initItems:->
    for i in @player.backpack when i.type is "item"
      @addSourceItem i
    for i in @player.storage when i.type is "item"
      @addSourceItem i
  addSourceItem:(item)->
    w = new SourceItem @UI['source-item-tpl'].innerHTML,this,item
    w.appendTo @UI['source-list']
      
class window.Worktable extends Layer
  constructor:(home)->
    super
    @home = home
    @game = home.game
    @db = @game.db
    @player = @game.player
    @floor = home.secondFloor
    @menu = new WorktableMenu Res.tpls['worktable-menu'],this
    @menu.show()
  putInItem:(item)->
    #console.log "put in item",item
    if item.playerItem.number > 1
      item.playerItem.number -= 1
      item.update()
    else
      @player.removeThing item.playerItem
      @menu.detailsBox.locked = true
      @menu.detailsBox.J.fadeOut "fast",=>
        @menu.detailsBox.locked = false
      item.J.slideUp 150,->
        item.remove()
    @menu.reactionBox.putInItem item.playerItem
  close:->
    @menu.hide()
    @fadeOut 150,=>
      @emit "close"

