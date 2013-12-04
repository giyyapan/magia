class window.StartMenu extends Stage
  constructor:(game)->
    super game
    @menu = new Menu Res.tpls['start-menu']
    bg = new Layer Res.imgs.startBg
    @bgLight = new Layer Res.imgs.startBgLight
    @drawQueueAdd bg,@bgLight
    @initMenu()
    @soundOff = false
    @changeBgClock = new Clock "fast",=>
      @changeBgClock.paused = true
      @bgLight.animate {"transform.opacity":Math.random()},200,=>
        @changeBgClock.paused = false
  tick:(tickDelay)->
    @changeBgClock.tick tickDelay
  initMenu: ->
    $(".logo-holder").animate opacity:"1",1000
    if not localStorage.playerData then @menu.UI.start.J.hide()
    @menu.UI["logo-line"].J.animate width:"+=620px",800,=>
        @menu.UI["logo-bg"].J.animate opacity:"1",1500
        @menu.UI["logo-text"].J.animate {opacity:"1",right:"+=80px"},1500
        @menu.UI["start-but"].J.show().animate opacity:"1",1000
    @menu.UI.start.onclick = =>
      console.log  "start game btn click"
      AudioManager.play("startClick")
      @game.player.loadData()
      lastStage = @game.player.data.lastStage
      @game.switchStage lastStage
    @menu.UI.sound.onclick = =>
      if @soundOff
        AudioManager.soundOn()
        @soundOff = false
        @menu.UI.sound.J.text "关闭声音"
      else
        AudioManager.soundOff()
        @soundOff = true
        @menu.UI.sound.J.text "打开声音"
    @menu.UI.newgame.onclick = =>
      console.log  "new game btn click"
      AudioManager.play("startClick")
      f = =>
        window.localStorage.clear()
        @game.player.newData()
        @game.storyManager.showStory "start1"
      if window.localStorage.playerData
        new PopupBox "警告","重新开始游戏将会清除你当前的所有数据</br>确定要继续吗？",f
      else
        f()
    @menu.UI.test.onclick = =>
      console.log  "test btn click"
      AudioManager.play("startClick")
      @game.switchStage "test"
    @menu.UI["start-but"].onclick = =>
      @showSubMenu()
    @menu.show()
    for but in document.getElementsByTagName("button")
      but.onmouseover = ->
        AudioManager.play "sfxStartCusor"
  showSubMenu:->
    #console.log "start-but click"
    AudioManager.play("startClick")
    @menu.UI["logo-holder"].J.animate {bottom:"100px"},500
    @menu.UI["start-but"].J.fadeOut "fast",=>
      animateBtn = (btnJ)->
        window.setTimeout (->
          btnJ.animate {right:"+=150px",opacity:"1"}, 500
        ),index*60
      @menu.UI["sub-btn-list"].J.show()
      for dom,index in @menu.UI["sub-btn-list"].J.find(".start-but")
        J = $(dom)
        J.css "right","-=150px"
        animateBtn J

   





