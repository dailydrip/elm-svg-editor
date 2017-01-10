module View exposing (view)

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
import Pure
import Model exposing (Model, MouseModel)
import Msg exposing (Msg)


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
        []


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
