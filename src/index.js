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

// Prepare to use the Google authentication provider
let provider = new firebase.auth.GoogleAuthProvider()
provider.addScope('https://www.googleapis.com/auth/plus.login')

// Listen for requests to authenticate
app.ports.requestAuthentication.subscribe(() => {
  // Pop up a new window - we can redirect if we're dealing with mobile
  firebase.auth().signInWithPopup(provider).then(function(result) {
    // This gives you a Google Access Token. You can use it to access the Google API.
    let token = result.credential.accessToken
    // The signed-in user info.
    let user = result.user
    console.log("signed in", user)
    app.ports.receiveUser.send(user)
  }).catch((error) => {
    // Handle Errors here.
    let errorCode = error.code
    let errorMessage = error.message
    // The email of the user's account used.
    let email = error.email
    // The firebase.auth.AuthCredential type that was used.
    let credential = error.credential
    console.log("error authenticating", errorMessage)
  })
})

app.ports.logOut.subscribe(() => {
  firebase.auth().signOut()
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
