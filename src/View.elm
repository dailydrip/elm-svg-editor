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
import Msg exposing (Msg(SelectShape))
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
import Svg.Events exposing (onClick)
import Dict exposing (Dict)


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
            , drawingArea model.shapes
            ]
        ]


drawingArea : Dict Int Shape -> Html Msg
drawingArea shapesDict =
    section
        [ class <| "drawing-area " ++ Pure.unit [ "7", "8" ] ]
        [ svg
            [ viewBox "0 0 100 100"
            , preserveAspectRatio "xMidYMin slice"
            ]
            (viewShapes shapesDict)
        ]


viewShapes : Dict Int Shape -> List (Svg Msg)
viewShapes shapesDict =
    shapesDict
        |> Dict.map viewShape
        |> Dict.toList
        |> List.map Tuple.second


viewShape : Int -> Shape -> Svg Msg
viewShape shapeId shape =
    case shape of
        Rect rectModel ->
            viewRect shapeId rectModel

        Circle circleModel ->
            viewCircle shapeId circleModel


viewRect : Int -> RectModel -> Svg Msg
viewRect shapeId rectModel =
    rect
        [ x (toString rectModel.x)
        , y (toString rectModel.y)
        , width (toString rectModel.width)
        , height (toString rectModel.height)
        , stroke rectModel.stroke
        , fill rectModel.fill
        , onClick <| SelectShape shapeId
        ]
        []


viewCircle : Int -> CircleModel -> Svg Msg
viewCircle shapeId circleModel =
    circle
        [ cx (toString circleModel.cx)
        , cy (toString circleModel.cy)
        , r (toString circleModel.r)
        , stroke circleModel.stroke
        , fill circleModel.fill
        , onClick <| SelectShape shapeId
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
