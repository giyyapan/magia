class DialogBox extends Menu
  constructor:->
    super Res.tpls['dialog-box']
    @displayInterval = null
    @displayLock = false
    @UI['content-wrapper'].onclick = =>
      @immediatelyDisplay()
  endDisplay:->
    window.clearInterval @displayInterval
    @displayLock = false
    @UI.text.innerHTML = @currentDisplayData.text
  display:(data,callback)->
    return if @displayLock
    @displayLock = true
    @currentDisplayData = data
    return if not data.text
    arr = data.text.split ""
    index = 0
    @UI.text.innerHTML = ""
    @displayInterval = window.setInterval (=>
      if index < arr.length
        index += 1
        @UI.text.innerHTML += arr[index]
      else
        @endDisplay()
      ),50
  show:(callback)->
    @UILayer.J.find("menu").fadeOut "fast",=>
      @J.hide()
      @appendTo @UILayer.dom
      @J.fadeIn "fast",->
        callback() if callback
  hide:(callback)->
    @J.fadeOut "fast",=>
      @UILayer.J.find("menu").fadeIn "fast"
      @remove()
      callback() if callback
    
    
