(function() {
  var conf, dom, p, s, script, scriptContainer, _i, _len, _ref;

  conf = {
    debug: 2,
    showFPS: true,
    frameRate: 60,
    script: ['js/base.js', 'js/utils.js', 'js/player.js', 'js/startScene.js', 'js/resource.js', 'js/magia.js']
  };

  if (!document.createElement('canvas').getContext) {
    dom = document.createElement('div');
    dom.innerHTML = '<h2>Your browser does not support HTML5 canvas!</h2>' + '<p>Google Chrome is a browser that combines a minimal design with sophisticated technology to make the web faster, safer, and easier.Click the logo to download.</p>' + '<a href="http://www.google.com/chrome" target="_blank"><img src="http://www.google.com/intl/zh-CN/chrome/assets/common/images/chrome_logo_2x.png" border="0"/></a>';
    p = document.body;
    p.style.background = 'none';
    p.style.border = 'none';
    p.insertBefore(dom);
    document.body.style.background = '#ffffff';
  }

  window.gameConfig = conf;

  scriptContainer = $("#script-container").get(0);

  _ref = conf.script;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    script = _ref[_i];
    s = document.createElement('script');
    s.src = script;
    scriptContainer.appendChild(s);
  }

}).call(this);
