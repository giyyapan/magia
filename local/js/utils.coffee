window.Utils =
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

