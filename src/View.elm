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
import Model
    exposing
        ( Model
        , MouseModel
        , RectModel
        , CircleModel
        , Shape(..)
        )
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
    let
        rectModel =
            { x = "20"
            , y = "20"
            , width = "20"
            , height = "20"
            , stroke = "black"
            , fill = "transparent"
            }

        circleModel =
            { cx = "50"
            , cy = "20"
            , r = "5"
            , stroke = "red"
            , fill = "yellow"
            }
    in
        section
            [ class <| "drawing-area " ++ Pure.unit [ "7", "8" ] ]
            [ svg
                [ viewBox "0 0 100 100"
                , preserveAspectRatio "xMidYMin slice"
                ]
                [ viewShape (Rect rectModel)
                , viewShape (Circle circleModel)
                ]
            ]


viewShape : Shape -> Svg Msg
viewShape shape =
    case shape of
        Rect rectModel ->
            viewRect rectModel

        Circle circleModel ->
            viewCircle circleModel


viewRect : RectModel -> Svg Msg
viewRect rectModel =
    rect
        [ x rectModel.x
        , y rectModel.y
        , width rectModel.width
        , height rectModel.height
        , stroke rectModel.stroke
        , fill rectModel.fill
        ]
        []


viewCircle : CircleModel -> Svg Msg
viewCircle circleModel =
    circle
        [ cx circleModel.cx
        , cy circleModel.cy
        , r circleModel.r
        , stroke circleModel.stroke
        , fill circleModel.fill
        ]
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
