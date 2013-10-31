class window.StartMenu extends Stage
  constructor:(game)->
    super game
    @menu = new Menu Res.tpls['start-menu']
    @menu.UI.start.onclick = =>
      console.log  "start game btn click"
      lastStage = @game.player.data.lastStage
      @game.switchStage lastStage
    @menu.UI.test.onclick = =>
      console.log  "start game btn click"
      @game.switchStage "test"
    @menu.show()
    console.log @menu
