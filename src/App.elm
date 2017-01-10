module App exposing (..)

import Model exposing (Model, initialModel)
import Msg exposing (Msg(..))
import Mouse


init : () -> ( Model, Cmd Msg )
init flags =
    initialModel ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ mouse } as model) =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MouseMove pos ->
            let
                nextMouse =
                    { mouse | position = pos }
            in
                { model | mouse = nextMouse } ! []

        MouseDown pos ->
            let
                nextMouse =
                    { mouse | down = True }
            in
                { model | mouse = nextMouse } ! []

        MouseUp pos ->
            let
                nextMouse =
                    { mouse | down = False }
            in
                { model | mouse = nextMouse } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.moves MouseMove
        , Mouse.downs MouseDown
        , Mouse.ups MouseUp
        ]
