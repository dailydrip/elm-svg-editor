module App exposing (..)

import Html exposing (Html, text, div, dl, dd, dt, h2, section)
import Html.Attributes exposing (class)
import Mouse
import Pure


type alias Model =
    { mouse : MouseModel
    }


type alias MouseModel =
    { position : Mouse.Position
    , down : Bool
    }


initialModel : Model
initialModel =
    Model <|
        MouseModel { x = 0, y = 0 } False


init : () -> ( Model, Cmd Msg )
init flags =
    initialModel ! []


type Msg
    = NoOp
    | MouseMove Mouse.Position
    | MouseDown Mouse.Position
    | MouseUp Mouse.Position


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


view : Model -> Html Msg
view model =
    div
        [ class Pure.grid ]
        [ mouseStatus model.mouse
        , drawingArea
        ]


drawingArea : Html Msg
drawingArea =
    section
        [ class <| "drawing-area " ++ Pure.unit [ "7", "8" ] ]
        [ text "foo" ]


mouseStatus : MouseModel -> Html Msg
mouseStatus mouse =
    section
        [ class <| "mouse-status " ++ Pure.unit [ "1", "8" ] ]
        [ h2 [] [ text "Mouse" ]
        , dl []
            [ dt [] [ text "Position" ]
            , dd [] [ text <| toString mouse.position ]
            , dt [] [ text "Down?" ]
            , dd [] [ text <| toString mouse.down ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.moves MouseMove
        , Mouse.downs MouseDown
        , Mouse.ups MouseUp
        ]
