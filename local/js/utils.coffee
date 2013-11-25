window.Dict =
    QualityLevel:[30,100,200,300,500,800]
    TraitName:
      life:"生命"
      heal:"治疗"
      fire:"火焰"
      water:"水"
      wind:"风"
      earth:"地"
      air:"气"
      minus:"负能量"
      spirit:"灵能"
      snow:"雪"
      explode:"爆炸"
      burn:"燃烧"
      poison:"毒"
      clear:"净化"
      muddy:"泥泞"
      fog:"雾"
      iron:"钢"
      freeze:"霜冻"
      corrosion:"腐蚀"
      
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
  getKey:(s)->
    sum = 0
    for c,index in s
      sum += s.charCodeAt index
    return parseInt(sum << 3 | 555 % 10000)
for name of Suzaku.Utils
  window.Utils[name] = Suzaku.Utils[name]

