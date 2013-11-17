window.Utils =
  getSize:->
  drawRoundRect:(context,x,y,w,h,r1,r2,r3,r4)->
    if typeof r2 is "undefined"
      r2 = r1
      r3 = r1
      r4 = r1
    context.beginPath()
    context.moveTo(x+r1, y)
    context.arcTo(x+w, y, x+w, y+h, r2)
    context.arcTo(x+w, y+h, x, y+h, r3)
    context.arcTo(x, y+h, x, y, r4)
    context.arcTo(x, y, x+w, y, r1)
    context.closePath()
    return context
  setCSS3Attr:(dom,name,value)->
    J = $(dom)
    obj = {}
    obj["#{name}"] = value
    obj["-webkit-#{name}"] = value
    obj["-o-#{name}"] = value
    obj["-ms-#{name}"] = value
    obj["-moz-#{name}"] = value
    J.css obj
      
for name of Suzaku.Utils
  window.Utils[name] = Suzaku.Utils[name]

