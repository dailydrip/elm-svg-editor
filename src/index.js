// PureCSS styles
require('purecss/build/pure-min.css')
require('purecss/build/grids-responsive-min.css')
require('purecss/build/buttons-min.css')

// Custom styles
require('./main.css')

// Firebase
let firebase = require('firebase')
firebase.initializeApp({
  apiKey: "AIzaSyDP3V-9e3cpvMSf5c6NPRdMgkP4lAK3BeI",
  authDomain: "elm-svg-editor.firebaseapp.com",
  databaseURL: "https://elm-svg-editor.firebaseio.com",
  storageBucket: "elm-svg-editor.appspot.com",
  messagingSenderId: "1090218891778"
})
let database = firebase.database()

let Elm = require('./Main.elm')
let root = document.getElementById('root')
let app = Elm.Main.embed(root, null)

let ref = database.ref('shapes/2')
app.ports.persistShapes.subscribe((shapes) => {
  ref.set(shapes)
})
ref.on('value', (snapshot) => {
  let val = snapshot.val()
  delete val.ignoreme
  console.log(val)
  app.ports.receiveShapes.send(val)
})

// We add a quick function to find the svg element, given an ancestor
let getSvg = (el) => el.getElementsByTagName('svg')[0]

// Then we introduce an event listener on the document that tracks our
// `mousemove`s, converts them to viewbox-relative coordinates, and sends them
// via the port.
// NOTE: I found how to do this here: http://stackoverflow.com/a/20958980
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
