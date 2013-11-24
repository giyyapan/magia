class popBig extends Widget
  constructor: (tpl,data,game,name) ->
    super tpl
    window.heheGame = game
    @game = game
    @UI['title'].innerHTML = data.name
    @UI['description'].innerHTML = data.description
    @UI['danger-level'].innerHTML = data.dangerLevel
    @costEnergy = @UI['cost-energy']
    @costEnergy.innerHTML = data.costEnergy
    @dom.onclick = =>
      @css3Animate "animate-popout",400,=>
        @remove()
    @UI['popBig'].onclick = (evt)=>
      evt.stopPropagation()
    @UI['enter-btn'].onclick = =>
      console.log name
      if name is 'home' 
        @game.switchStage name
      else if name is 'shop'
        return true
      else
        nowEnergy = @game.player.energy
        if nowEnergy < data.costEnergy
          @css3Animate.call @costEnergy,"animate-warning",550
          @costEnergy.innerHTML = "#{data.costEnergy}(您的体力不足！！)"
        else
          @game.switchStage "area",name
          @game.player.energy -= data.costEnergy
          @game.player.saveData()
      
class MapPoint extends Widget
  constructor:(tpl,data,menu,game,name)->
    super tpl
    @menu = menu
    @UI["map-summary-name"].innerHTML = data.name
    console.log data.summaryImg.src
    @UI["map-summary-pic"].J.css "background", "url(#{Res.imgs[data.summaryImg].src})"
    console.log @dom
    @dom.onclick = =>
      myPopBig = new popBig @menu.UI['map-popBig-tpl'].innerHTML,data,game,name
      console.log @menu
      myPopBig.appendTo @menu

class window.WorldMap extends Stage
  constructor:(game)->
    super()
    @game = game
    map = new Layer()
    @player = @game.player
    @db = @game.db

    @menu = new Menu Res.tpls['world-map']
    map.setImg Res.imgs.worldMap
    #console.log @menu
    @menu.show()
    @drawQueueAddAfter map,@menu

    nowEnergy = @player.energy
    myDate = new Date()
    nowMon = myDate.getMonth()
    nowDay = myDate.getDate()
    nowHours = myDate.getHours()
    @menu.UI["energy"].innerHTML = "体力:" + nowEnergy
    @menu.UI["time"].innerHTML = "#{nowMon}月#{nowDay}日"
    if nowHours >0 and nowHours <20
      @menu.UI["day-night"].innerHTML = "昼"
    else
      @menu.UI["day-night"].innerHTML = "夜"



    for name in ["home","forest","snowmountain","shop"]
      data = @db.areas.get name
      imgName = data.summaryImg
      img = window.Res.imgs[imgName]
      newItem = new MapPoint @menu.UI['map-point-tpl'].innerHTML,data,@menu,game,name
      newItem.appendTo @menu.UI['map-summary-holder']

   

