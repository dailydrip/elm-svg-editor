module App exposing (..)

import Html
    exposing
        ( Html
        , a
        , dd
        , div
        , dl
        , dt
        , h1
        , h2
        , h3
        , header
        , p
        , section
        , text
        )
import Html.Attributes exposing (class, href)
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
    div []
        [ header
            []
            [ h1 [] [ text "Elm SVG Editor" ]
            , p []
                [ text "from "
                , a [ href "https://www.dailydrip.com" ] [ text "DailyDrip" ]
                ]
            ]
        , div
            [ class Pure.grid ]
            [ sidebar model.mouse
            , drawingArea
            ]
        ]


drawingArea : Html Msg
drawingArea =
    section
        [ class <| "drawing-area " ++ Pure.unit [ "7", "8" ] ]
        [ text "foo" ]


sidebar : MouseModel -> Html Msg
sidebar mouse =
    section
        [ class <| "sidebar " ++ Pure.unit [ "1", "8" ] ]
        [ h3 [] [ text "Mouse" ]
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
