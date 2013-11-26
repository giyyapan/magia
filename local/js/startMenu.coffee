class window.StartMenu extends Stage
  constructor:(game)->
    super game
    @menu = new Menu Res.tpls['start-menu']
    @initMenu()
  initMenu: ->
    $(".logo-holder").animate opacity:"1",1000
    @menu.UI["logo-line"].J.animate width:"+=620px",800,=>
        @menu.UI["logo-bg"].J.animate opacity:"1",1500
        @menu.UI["logo-text"].J.animate {opacity:"1",right:"+=80px"},1500
        @menu.UI["start-but"].J.show().animate opacity:"1",1000
    @menu.UI.start.onclick = =>
      console.log  "start game btn click"
      window.myAudio.play("startClick")
      lastStage = @game.player.data.lastStage
      @game.switchStage lastStage
    @menu.UI.test.onclick = =>
      console.log  "start game btn click"
      window.myAudio.play("startClick")
      @game.switchStage "test"
    @menu.show()
    console.log @menu
    @menu.UI["start-but"].onclick = =>
      @showSubMenu()
       #audio
    for but in document.getElementsByTagName("button")
      but.onmouseover = ->
        window.myAudio.play "sfxStartCusor"
  showSubMenu:->
    #console.log "start-but click"
    window.myAudio.play("startClick")
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

   





