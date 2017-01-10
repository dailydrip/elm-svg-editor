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
import Svg exposing (Svg, svg, rect, circle)
import Svg.Attributes as SA
    exposing
        ( viewBox
        , preserveAspectRatio
        , x
        , y
        , width
        , height
        , stroke
        , fill
        , r
        , cx
        , cy
        )


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
        [ svg
            [ viewBox "0 0 100 100"
            , preserveAspectRatio "xMidYMin slice"
            ]
            [ rect
                [ x "20"
                , y "20"
                , width "20"
                , height "20"
                , stroke "black"
                , fill "transparent"
                ]
                []
            , circle
                [ cx "50"
                , cy "20"
                , r "5"
                , stroke "red"
                , fill "yellow"
                ]
                []
            ]
        ]


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
