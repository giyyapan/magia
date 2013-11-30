class PopBig extends Widget
  constructor: (tpl,data,woldMap,name) ->
    super tpl
    @game = woldMap.game
    @woldMap = woldMap
    @UI['title'].innerHTML = data.name
    @UI['description'].innerHTML = data.description
    @UI['danger-level'].innerHTML = data.dangerLevel
    @costEnergy = @UI['cost-energy']
    @costEnergy.innerHTML = data.costEnergy
    @dom.onclick = =>
      @css3Animate "animate-pophide",=>
        @remove()
    @UI['popBig'].onclick = (evt)=>
      evt.stopPropagation()
    @UI['enter-btn'].onclick = =>
      switch name
        when "home" then return @game.switchStage "home"
        when "magicItemShop","equipmentShop" then return @game.switchStage "shop",name
        when "guild" then return @game.switchStage "guild"
        else
          nowEnergy = @game.player.energy
          if nowEnergy < data.costEnergy
            @css3Animate.call @costEnergy,"animate-warning"
            @costEnergy.innerHTML = "#{data.costEnergy}(您的体力不足！！)"
          else
            @game.switchStage "area",name
            @game.player.energy -= data.costEnergy
            @game.player.saveData()
      
class MapPoint extends Widget
  constructor:(tpl,data,menu,woldMap,name)->
    super tpl
    @menu = menu
    @UI["map-summary-name"].innerHTML = data.name
    @UI["map-summary-pic"].src = Res.imgs[data.summaryImg].src
    @dom.onclick = =>
      myPopBig = new PopBig @menu.UI['map-popBig-tpl'].innerHTML,data,woldMap,name
      myPopBig.appendTo @menu

class window.WorldMap extends Stage
  constructor:(game)->
    super()
    @game = game
    map = new Layer()
    @player = @game.player
    @db = @game.db
    @menu = new Menu Res.tpls['world-map']
    @menu.show()
    @areaItems = []
    @drawQueueAddAfter map,@menu
    nowEnergy = @player.energy
    myDate = new Date()
    nowMon = myDate.getMonth()
    nowDay = myDate.getDate()
    nowHours = myDate.getHours()
    @menu.UI["energy"].innerHTML = "体力:" + nowEnergy
    @menu.UI["time"].innerHTML = "#{nowMon+1} 月 #{nowDay} 日"
    if nowHours >0 and nowHours <20
      @menu.UI["day-night"].innerHTML = "昼"
    else
      @menu.UI["day-night"].innerHTML = "夜"
    for name in ["home","guild","magicItemShop","equipmentShop","forest","snowmountain"]
      data = @db.areas.get name
      imgName = data.summaryImg
      img = window.Res.imgs[imgName]
      newItem = new MapPoint @menu.UI['map-point-tpl'].innerHTML,data,@menu,this,name
      newItem.appendTo @menu.UI['map-summary-holder']
      @areaItems.push newItem
    if @areaItems.length > 4
      @menu.UI['map-summary-holder'].J.addClass "two-lines"
   

