// PureCSS styles
require('purecss/build/pure-min.css')
require('purecss/build/grids-responsive-min.css')
require('purecss/build/buttons-min.css')

// Custom styles
require('./main.css')

let Elm = require('./Main.elm')
let root = document.getElementById('root')
let app = Elm.Main.embed(root, null)

let getSvg = (el) => el.getElementsByTagName('svg')[0]

document.addEventListener('mousemove', (evt) => {
  let point, position
  let svg = getSvg(root)
  if(svg){
    point = svg.createSVGPoint()
    point.x = evt.clientX
    point.y = evt.clientY
    position = point.matrixTransform(svg.getScreenCTM().inverse())
    app.ports.receiveSvgMouseCoordinates.send({
      x: position.x,
      y: position.y
    })
  }
})
