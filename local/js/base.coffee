class window.Drawable
  constructor:(x,y,width,height)->
    @x = x
    @y = y
    @width = width
    @height = height
  draw:(context)->
    context.fillStype "black"
    context.fillRect @x,@y,@width,@height

class window.Scene extends Drawable
  constructor:->

class window.Layer extends Drawable
  constructor:->

class MenuButton extends Suzaku.Widget
  constructor:->
    
class window.Menu extends Suzaku.Widget
  constructor:->
