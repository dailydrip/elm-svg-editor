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
        , i
        , ul
        , li
        )
import Html.Attributes exposing (class, href, classList)
import Html.Events exposing (onWithOptions)
import Pure
import Model
    exposing
        ( Model
        , MouseModel
        , RectModel
        , CircleModel
        , Shape(..)
        , Tool(..)
        )
import Msg exposing (Msg(SelectShape, AddShape, SelectTool, NoOp, BeginDrag))
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
import Svg.Events exposing (onClick, on, onMouseDown)
import Dict exposing (Dict)
import FontAwesome.Web as Icon
import Json.Decode as Decode
import Drag exposing (DragAction(..))


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
            [ sidebar model.mouse model.selectedTool
            , drawingArea model.selectedShapeId model.shapes model.selectedTool model.mouse
            ]
        ]


drawingArea : Maybe Int -> Dict Int Shape -> Maybe Tool -> MouseModel -> Html Msg
drawingArea maybeSelectedShapeId shapesDict maybeSelectedTool mouse =
    section
        [ class <| "drawing-area " ++ Pure.unit [ "7", "8" ] ]
        [ svg
            [ viewBox "0 0 1000 1000"
            , preserveAspectRatio "xMidYMin slice"
            , onClick (onDrawingAreaClick maybeSelectedTool mouse)
            ]
            (viewShapes maybeSelectedShapeId shapesDict)
        ]


onDrawingAreaClick : Maybe Tool -> MouseModel -> Msg
onDrawingAreaClick maybeTool mouse =
    case maybeTool of
        Nothing ->
            NoOp

        Just tool ->
            case tool of
                RectTool ->
                    AddShape <|
                        (Rect
                            { x = mouse.svgPosition.x
                            , y = mouse.svgPosition.y
                            , width = 100
                            , height = 100
                            , stroke = "green"
                            , strokeWidth = 10
                            , fill = "transparent"
                            }
                        )

                CircleTool ->
                    AddShape <|
                        (Circle
                            { cx = mouse.svgPosition.x
                            , cy = mouse.svgPosition.y
                            , r = 25
                            , stroke = "yellow"
                            , strokeWidth = 10
                            , fill = "red"
                            }
                        )


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
        dragHandleWidth =
            20

        dragHandle =
            rect
                [ x
                    (toString
                        (rectModel.x + rectModel.width)
                    )
                , y
                    (toString
                        (rectModel.y + rectModel.height)
                    )
                , width (toString dragHandleWidth)
                , height (toString dragHandleWidth)
                , stroke "yellow"
                , strokeWidth "2"
                , strokeDasharray "4,4"
                , fill "transparent"
                , SA.class "rect-selection-drag-handle"
                , onMouseDownPreventingDefault <| BeginDrag DragResize
                ]
                []

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
                , SA.class "selection rect-selection"
                ]
                []

        groupChildren =
            if selected then
                [ viewUnselectedRect shapeId rectModel
                , rectSelection
                , dragHandle
                ]
            else
                [ viewUnselectedRect shapeId rectModel ]
    in
        g
            [ onClickPreventingDefault <| SelectShape shapeId
            ]
            groupChildren


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
        ]
        []


viewCircle : Bool -> Int -> CircleModel -> Svg Msg
viewCircle selected shapeId circleModel =
    let
        dragHandleWidth =
            20

        dragHandle =
            rect
                [ x
                    (toString
                        (circleModel.cx + circleModel.r)
                    )
                , y
                    (toString circleModel.cy)
                , width (toString dragHandleWidth)
                , height (toString dragHandleWidth)
                , stroke "yellow"
                , strokeWidth "2"
                , strokeDasharray "4,4"
                , fill "transparent"
                , SA.class "circle-selection-drag-handle"
                , onMouseDownPreventingDefault <| BeginDrag DragResize
                ]
                []

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
                , dragHandle
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
        , onClickPreventingDefault <| SelectShape shapeId
        ]
        []


sidebar : MouseModel -> Maybe Tool -> Html Msg
sidebar mouse selectedTool =
    section
        [ class <| "sidebar " ++ Pure.unit [ "1", "8" ] ]
        [ div
            [ class "tools" ]
            [ h3 [] [ text "Tools" ]
            , ul []
                [ li
                    [ onClick <| SelectTool RectTool
                    , classList
                        [ ( "selected"
                          , selectedTool
                                == Just
                                    RectTool
                          )
                        ]
                    ]
                    [ Icon.square_o ]
                , li
                    [ onClick <| SelectTool CircleTool
                    , classList
                        [ ( "selected"
                          , selectedTool
                                == Just
                                    CircleTool
                          )
                        ]
                    ]
                    [ Icon.circle_o ]
                ]
            ]
        , h3 [] [ text "Mouse" ]
        , dl []
            [ dt [] [ text "Position" ]
            , dd [] [ text <| toString mouse.position ]
            , dt [] [ text "SVG Position" ]
            , dd [] [ text <| toString mouse.svgPosition ]
            , dt [] [ text "Down?" ]
            , dd [] [ text <| toString mouse.down ]
            ]
        ]


onClickPreventingDefault : Msg -> Svg.Attribute Msg
onClickPreventingDefault msg =
    onWithOptions
        "click"
        { preventDefault = False
        , stopPropagation = True
        }
        (Decode.succeed <| msg)


onMouseDownPreventingDefault : Msg -> Svg.Attribute Msg
onMouseDownPreventingDefault msg =
    onWithOptions
        "mousedown"
        { preventDefault = False
        , stopPropagation = True
        }
        (Decode.succeed <| msg)
