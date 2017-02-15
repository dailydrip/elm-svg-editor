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
let storage = firebase.storage()

let Elm = require('./Main.elm')
let root = document.getElementById('root')
let app = Elm.Main.embed(root, null)

let basePath = 'shapes/2'
let dbRef = database.ref(basePath)
app.ports.persistShapes.subscribe((shapes) => {
  dbRef.set(shapes)
})

app.ports.storeFile.subscribe((id) => {
  // Get the element by id
  let node = document.getElementById(id)
  if (node === null) {
    return
  }

  // Get the file and make a new FileReader
  // If your file upload field allows multiple files, you might
  // want to consider turning this into a `for` loop.
  let file = node.files[0]
  let reader = new FileReader()

  // FileReader API is event based. Once a file is selected
  // it fires events. We hook into the `onload` event for our reader.
  reader.onload = (event) => {
    // The event carries the `target`. The `target` is the file
    // that was selected. The result is base64 encoded contents of the file.
    let base64encoded = event.target.result;
    // We build up an object that has our file contents and file name.
    let fileData = {
      contents: base64encoded,
      filename: file.name
    }

    // We build the path that we'll use to store the file
    let path = basePath + '/' + fileData.filename
    // and we generate a reference to that path on the storage system
    let storageRef = storage.ref(path)

    // We create a new uploadTask for putting our data into Firebase. We'll use
    // `putString` for this because we get a data url version of the file from
    // our event's target.
    let uploadTask =
      storageRef
        .putString(fileData.contents, firebase.storage.StringFormat.DATA_URL)

    // Then when the state changes for our uploadTask, we'll handle it.
    // This function takes three callbacks:
    //
    // - next, for when new things happen
    // - error, for when there are errors
    // - complete, for when the file upload has completed
    uploadTask.on(firebase.storage.TaskEvent.STATE_CHANGED,
      // In-progress callback
      // When the 'next' event fires, we'll determine the progress of the
      // upload, and send a file storage update record into our Elm app.
      (snapshot) => {
        let progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100
        // We want to know if it's paused or running
        switch (snapshot.state) {
          case firebase.storage.TaskState.PAUSED:
            app.ports.receiveFileStorageUpdate.send({paused: progress})
            break
          case firebase.storage.TaskState.RUNNING:
            app.ports.receiveFileStorageUpdate.send({running: progress})
            break
        }
      },
      // Error callback
      // If there's an error, we need to tell the app about it
      (error) => {
        app.ports.receiveFileStorageUpdate.send({error: error.message})
      },
      // Success callback
      // When we succeed, we'll send a 'complete' update and tell the Elm app
      // where the uploaded file can be accessed publicly.
      () => {
        app.ports.receiveFileStorageUpdate.send({complete: uploadTask.snapshot.downloadURL})
      }
    )
  }

  // Finally, we'll tell the reader to read the file
  // Connect our FileReader with the file that was selected in our `input` node.
  reader.readAsDataURL(file);
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

dbRef.on('value', (snapshot) => {
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
