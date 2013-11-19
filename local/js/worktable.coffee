class WorktableMenu extends Menu
  constructor:(tpl,worktable)->
    super tpl
    @worktable = worktable
    @UI['exit-btn'].onclick = =>
      @worktable.close()
      
class window.Worktable extends Layer
  constructor:(home)->
    super
    @home = home
    @floor = home.secondFloor
    @menu = new WorktableMenu Res.tpls['worktable-menu'],this
    @menu.show()
  close:->
    @menu.hide()
    @fadeOut 150,=>
      @emit "close"
