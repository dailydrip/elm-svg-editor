module App exposing (..)

import Model exposing (Model, initialModel)
import Msg exposing (Msg(..))
import Mouse
import Ports


init : () -> ( Model, Cmd Msg )
init flags =
    initialModel ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.moves MouseMove
        , Mouse.downs MouseDown
        , Mouse.ups MouseUp
        , Ports.receiveSvgMouseCoordinates MouseSvgMove
        , Ports.receiveShapes ReceiveShapes
        , Ports.receiveUser ReceiveUser
        ]
