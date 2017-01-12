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
import Svg exposing (Svg, svg, rect, circle, g)
import Svg.Attributes as SA
    exposing
        ( viewBox
        , preserveAspectRatio
        , x
        , y
        , width
        , height
        , stroke
        , strokeWidth
        , strokeDasharray
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
            , drawingArea model.selectedShapeId model.shapes
            ]
        ]


drawingArea : Maybe Int -> Dict Int Shape -> Html Msg
drawingArea maybeSelectedShapeId shapesDict =
    section
        [ class <| "drawing-area " ++ Pure.unit [ "7", "8" ] ]
        [ svg
            [ viewBox "0 0 1000 1000"
            , preserveAspectRatio "xMidYMin slice"
            ]
            (viewShapes maybeSelectedShapeId shapesDict)
        ]


viewShapes : Maybe Int -> Dict Int Shape -> List (Svg Msg)
viewShapes maybeSelectedShapeId shapesDict =
    shapesDict
        |> Dict.map (viewShape maybeSelectedShapeId)
        |> Dict.toList
        |> List.map Tuple.second


viewShape : Maybe Int -> Int -> Shape -> Svg Msg
viewShape maybeSelectedShapeId shapeId shape =
    let
        selected =
            case maybeSelectedShapeId of
                Just selectedShapeId ->
                    selectedShapeId == shapeId

                Nothing ->
                    False
    in
        case shape of
            Rect rectModel ->
                viewRect selected shapeId rectModel

            Circle circleModel ->
                viewCircle selected shapeId circleModel


viewRect : Bool -> Int -> RectModel -> Svg Msg
viewRect selected shapeId rectModel =
    let
        rectSelection =
            rect
                [ x (toString (rectModel.x - (rectModel.strokeWidth / 2)))
                , y (toString (rectModel.y - (rectModel.strokeWidth / 2)))
                , width (toString (rectModel.width + rectModel.strokeWidth))
                , height (toString (rectModel.height + rectModel.strokeWidth))
                , stroke "yellow"
                , strokeWidth "2"
                , strokeDasharray "4,4"
                , fill "transparent"
                ]
                []

        groupChildren =
            if selected then
                [ viewUnselectedRect shapeId rectModel
                , rectSelection
                ]
            else
                [ viewUnselectedRect shapeId rectModel ]
    in
        g [] groupChildren


viewUnselectedRect : Int -> RectModel -> Svg Msg
viewUnselectedRect shapeId rectModel =
    rect
        [ x (toString rectModel.x)
        , y (toString rectModel.y)
        , width (toString rectModel.width)
        , height (toString rectModel.height)
        , stroke rectModel.stroke
        , strokeWidth (toString rectModel.strokeWidth)
        , fill rectModel.fill
        , onClick <| SelectShape shapeId
        ]
        []


viewCircle : Bool -> Int -> CircleModel -> Svg Msg
viewCircle selected shapeId circleModel =
    let
        circleSelection =
            circle
                [ cx (toString circleModel.cx)
                , cy (toString circleModel.cy)
                , r (toString (circleModel.r + (circleModel.strokeWidth / 2)))
                , stroke "yellow"
                , strokeWidth "2"
                , strokeDasharray "4,4"
                , fill "transparent"
                ]
                []

        groupChildren =
            if selected then
                [ viewUnselectedCircle shapeId circleModel
                , circleSelection
                ]
            else
                [ viewUnselectedCircle shapeId circleModel ]
    in
        g [] groupChildren


viewUnselectedCircle : Int -> CircleModel -> Svg Msg
viewUnselectedCircle shapeId circleModel =
    circle
        [ cx (toString circleModel.cx)
        , cy (toString circleModel.cy)
        , r (toString circleModel.r)
        , stroke circleModel.stroke
        , strokeWidth (toString circleModel.strokeWidth)
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
