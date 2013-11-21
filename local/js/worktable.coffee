class ReactionBox extends Widget
  constructor:(tpl,menu)->
    super tpl
    @menu = menu
    @worktable = menu.worktable
    @traitsItems = {}
    @reactions = []
    @reactionBtns = {}
    @initReactions()
  initReactions:->
    for r in @worktable.db.rules.get "reaction"
      fromTraitsArr = r.split("->")[0].split(",")
      obj =
        from:
          length:fromTraitsArr.length
        to:r.split("->")[1]
      for traits in fromTraitsArr 
        t = traits.split(":")
        obj.from[t[0]] = parseInt t[1]
      @reactions.push obj
  putInItem:(playerItem)->
    for name,value of playerItem.traits
      if not @traitsItems[name]
        @traitsItems[name] = new TraitsItem(name,value).appendTo @UI['current-traits-list']
      else
        i = @traitsItems[name]
        old = i.traitsValue
        i.changeValue parseInt(value*value/(old+value) + old)
    @tryReaction()
  tryReaction:->
    for r in @reactions
      avail = 0 #0:not avail 1:not enough 2:avail
      for name,value of r.from
        if not @traitsItems[name]
          avail = 0
          break
        if @traitsItems[name].traitsValue >= value
          if avail = 0 then avail = 2
        else
          avail = 1
      switch avail
        when 0 then continue
        when 1 then @addReactionBtn r,false
        when 2 then @addReactionBtn r,true
  addReactionBtn:(r,avail)->
    if @reactionBtns[r.to]
      @reactionBtns[r.to].update(avail)
    else
      tpl = @UI["reaction-btn-tpl-#{r.from.length}"]
      btn = new ReactionBtn tpl,r,avail
      btn.appendTo @UI['avail-reaction-box']
      @reactionBtns[r.to] = btn
      
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
    console.log this
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
