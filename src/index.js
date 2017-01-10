// PureCSS styles
require('purecss/build/pure-min.css')
require('purecss/build/grids-responsive-min.css')
require('purecss/build/buttons-min.css')

// Custom styles
require('./main.css')

let Elm = require('./Main.elm')

let root = document.getElementById('root')

Elm.Main.embed(root, null)
