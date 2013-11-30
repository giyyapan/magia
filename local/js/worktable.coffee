class ReactionFinishBox extends PopupBox
  constructor:(@reactionBox,@db)->
    title = "装瓶"
    hint = "请选择要保留的属性</br><small>有一些中间属性无法被制作成药剂</small>"
    super title,hint
    @UI['content-list'].J.show()
    @UI['accept'].J.hide()
    @dom.id = "reaction-finish-box"
    self = this
    for name,i of @reactionBox.traitItems
      if not @db.things.supplies.get "#{i.traitName}Potion"
        console.log "no supplies for trait : #{i.traitName}"
        continue
      item = new TraitItem(i.traitName,i.traitValue)
      console.log "finish add trait",item
      item.appendTo @UI['content-list']
      item.dom.widget = item
      item.dom.onclick = ->
        self.chooseTraitItem this.widget
    @show()
  chooseTraitItem:(item)->
    name = "#{item.traitName}Potion"
    newSupplies = new PlayerSupplies @db,name,traitValue:item.traitValue
    @emit "getNewSupplies",newSupplies
    @close()
    
class ReactionTraitItem extends TraitItem
  constructor:->
    super
    @J.addClass "animate-popup"
    
class ReactionConfirmBox extends PopupBox
  constructor:(reaction)->
    super "合成新属性"
    str = ""
    for name of reaction.from
      str += "<span class='trait-icon #{name}'>#{Dict.TraitName[name]}</span>"
    targetStr = "<span class=trait-icon '#{name}'>#{Dict.TraitName[reaction.to]}</span>"
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
      span.J.text Dict.TraitName[name].split("")[0]
    @update avail
    @J.removeClass "hide"
    @J.addClass "animate-popup"
    @dom.onclick = => 
      return if not @avail
      @reactionBox.react @reaction,=>
        @css3Animate "animate-popout",->@remove()
  remove:->
    layer = @worktable
    scale = 0
    @css3Animate "animate-popout",->
      @J.animate {width:0,height:0,margin:0},200,=>
        delete @reactionBox.reactionBtns[@reaction.to]
        super
  update:(avail)->
    @avail = avail
    if @avail
      span = @UI.target
      span.J.show()
      span.J.removeClass()
      span.J.addClass "target",@reaction.to
      span.J.text Dict.TraitName[@reaction.to].split("")[0]
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
    @traitItems = {}
    @reactions = []
    @reactionBtns = {}
    @initReactions()
    console.log @reactions
    @UI['finish'].onclick = =>
      @finishReaction()
  finishReaction:->
    box = new ReactionFinishBox this,@worktable.game.db
    box.on "getNewSupplies",(s)=>
      for n,i of @traitItems
        i.remove()
      @traitItems = {}
      new MsgBox("获得物品","你获得了#{s.dspName}！")
      @worktable.game.player.getSupplies "backpack",s
  initReactions:->
    for r in @worktable.db.rules.get "reaction"
      fromTraitsArr = r.split("->")[0].split(",")
      obj =
        from:{}
        fromTraitsCount:fromTraitsArr.length
        to:r.split("->")[1]
      for trait in fromTraitsArr 
        t = trait.split(":")
        obj.from[t[0]] = parseInt t[1]
      @reactions.push obj
  putInItem:(playerItem)->
    for name,value of playerItem.traits
      if not @traitItems[name]
        @traitItems[name] = new ReactionTraitItem(name,value).insertTo @UI['current-traits-list']
      else
        i = @traitItems[name]
        old = i.traitValue
        console.log i
        i.changeValue parseInt(value*value/(old+value) + old)
    @tryReaction()
  tryReaction:->
    for r in @reactions
      avail = 0 #0:not avail 1:not enough 2:avail
      for name,lvValue of r.from
        if not @traitItems[name]
          avail = 0
          break
        if @traitItems[name].lv >= lvValue
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
      tpl = @UI["reaction-btn-tpl-#{r.fromTraitsCount}"].innerHTML
      btn = new ReactionBtn tpl,r,avail,this
      btn.appendTo @UI['avail-reaction-list']
      @reactionBtns[r.to] = btn
  react:(reaction,callback)->
    console.log "react",reaction
    value = 0
    for name of reaction.from
      value += parseInt @traitItems[name].traitValue
    box = new ReactionConfirmBox reaction
    box.on "accept",=>
      value = value/reaction.fromTraitsCount
      callback() if callback
      newTraits = {}
      newTraits[reaction.to] = value
      @combineTraitItems(reaction,newTraits)
  combineTraitItems:(reaction,newTraits)->
    self = this
    items = []
    items.push @traitItems[name] for name of reaction.from
    for i,index in items
      targetTop = @UI['traits-box'].offsetTop
      i.dom.traitName = i.traitName
      i.css3Animate "animate-popout",->
        this.J.animate {height:0,margin:0},200,=>
          @remove()
          delete self.traitItems[this.traitName]
    @putInItem traits:newTraits
      
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
    
class SourceItem extends ListItem
  constructor:(tpl,menu,playerItem)->
    super tpl,playerItem
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

