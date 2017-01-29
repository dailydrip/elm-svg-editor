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
import FontAwesome.Web as Icon
import Html.Attributes exposing (class, href, classList)
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
import Msg
    exposing
        ( Msg
            ( SelectShape
            , DeselectShape
            , AddShape
            , SelectTool
            , NoOp
            , BeginDrag
            , EndDrag
            , SelectedShapeAction
            )
        , ShapeAction(..)
        )
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
import Html.Events exposing (onWithOptions)
import Dict exposing (Dict)
import Drag exposing (DragAction(..))
import Json.Decode as Decode


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
            [ sidebar model.selectedShapeId model.shapes model.mouse model.selectedTool
            , drawingArea
                model.selectedShapeId
                model.shapes
                model.selectedTool
                model.mouse
                model.shapeOrdering
            ]
        ]


drawingArea :
    Maybe Int
    -> Dict Int Shape
    -> Tool
    -> MouseModel
    -> Dict Int Int
    -> Html Msg
drawingArea maybeSelectedShapeId shapesDict selectedTool mouse shapeOrdering =
    section
        [ class <| "drawing-area " ++ Pure.unit [ "7", "8" ] ]
        [ svg
            [ viewBox "0 0 1000 1000"
            , preserveAspectRatio "xMidYMin slice"
            , onClick (onDrawingAreaClick selectedTool mouse)
            ]
            (viewShapes selectedTool
                maybeSelectedShapeId
                shapesDict
                shapeOrdering
            )
        ]


viewShapes : Tool -> Maybe Int -> Dict Int Shape -> Dict Int Int -> List (Svg Msg)
viewShapes selectedTool maybeSelectedShapeId shapesDict shapeOrdering =
    shapesDict
        |> Dict.map (viewShape selectedTool maybeSelectedShapeId)
        |> Dict.toList
        |> List.sortBy
            (\( id, _ ) ->
                Dict.get id shapeOrdering
                    |> Maybe.withDefault 0
            )
        |> List.map Tuple.second


viewShape : Tool -> Maybe Int -> Int -> Shape -> Svg Msg
viewShape selectedTool maybeSelectedShapeId shapeId shape =
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
                viewRect selectedTool selected shapeId rectModel

            Circle circleModel ->
                viewCircle selectedTool selected shapeId circleModel


selectionAttributes : Tool -> List (Svg.Attribute Msg)
selectionAttributes tool =
    let
        onSelectionClick : List (Svg.Attribute Msg)
        onSelectionClick =
            case tool of
                PointerTool ->
                    [ onClickPreventingDefault <| NoOp ]

                _ ->
                    []
    in
        [ stroke "yellow"
        , strokeWidth "2"
        , strokeDasharray "4,4"
        , fill "transparent"
        , SA.class "selection"
        , onMouseDownPreventingDefault <| BeginDrag DragMove
        ]
            ++ onSelectionClick


viewRect : Tool -> Bool -> Int -> RectModel -> Svg Msg
viewRect selectedTool selected shapeId rectModel =
    let
        rectSelection =
            rect
                ([ x (toString (rectModel.x - (rectModel.strokeWidth / 2)))
                 , y (toString (rectModel.y - (rectModel.strokeWidth / 2)))
                 , width (toString (rectModel.width + rectModel.strokeWidth))
                 , height (toString (rectModel.height + rectModel.strokeWidth))
                 ]
                    ++ (selectionAttributes selectedTool)
                )
                []

        groupChildren =
            if selected then
                [ viewUnselectedRect selectedTool shapeId rectModel
                , rectSelection
                , dragHandle
                    ( rectModel.x + rectModel.width
                    , rectModel.y + rectModel.height
                    )
                ]
            else
                [ viewUnselectedRect selectedTool shapeId rectModel ]
    in
        g [] groupChildren


viewUnselectedRect : Tool -> Int -> RectModel -> Svg Msg
viewUnselectedRect selectedTool shapeId rectModel =
    rect
        ([ x (toString rectModel.x)
         , y (toString rectModel.y)
         , width (toString rectModel.width)
         , height (toString rectModel.height)
         , stroke rectModel.stroke
         , strokeWidth (toString rectModel.strokeWidth)
         , fill rectModel.fill
         ]
            ++ (onShapeClick selectedTool shapeId)
        )
        []


viewCircle : Tool -> Bool -> Int -> CircleModel -> Svg Msg
viewCircle selectedTool selected shapeId circleModel =
    let
        circleSelection =
            circle
                ([ cx (toString circleModel.cx)
                 , cy (toString circleModel.cy)
                 , r (toString (circleModel.r + (circleModel.strokeWidth / 2)))
                 ]
                    ++ (selectionAttributes selectedTool)
                )
                []

        groupChildren =
            if selected then
                [ viewUnselectedCircle selectedTool shapeId circleModel
                , circleSelection
                , dragHandle
                    ( circleModel.cx + circleModel.r
                    , circleModel.cy
                    )
                ]
            else
                [ viewUnselectedCircle selectedTool shapeId circleModel ]
    in
        g [] groupChildren


onShapeClick : Tool -> Int -> List (Svg.Attribute Msg)
onShapeClick selectedTool shapeId =
    case selectedTool of
        PointerTool ->
            [ onClickPreventingDefault <| SelectShape shapeId ]

        _ ->
            []


viewUnselectedCircle : Tool -> Int -> CircleModel -> Svg Msg
viewUnselectedCircle selectedTool shapeId circleModel =
    circle
        ([ cx (toString circleModel.cx)
         , cy (toString circleModel.cy)
         , r (toString circleModel.r)
         , stroke circleModel.stroke
         , strokeWidth (toString circleModel.strokeWidth)
         , fill circleModel.fill
         ]
            ++ (onShapeClick selectedTool shapeId)
        )
        []


tools : List ( Tool, Html Msg )
tools =
    [ ( PointerTool, Icon.mouse_pointer )
    , ( RectTool, Icon.square_o )
    , ( CircleTool, Icon.circle_o )
    ]


sidebarTool : Tool -> ( Tool, Html Msg ) -> Html Msg
sidebarTool selectedTool ( tool, icon ) =
    li
        [ onClick <| SelectTool tool
        , classList
            [ ( "selected"
              , selectedTool == tool
              )
            ]
        ]
        [ icon ]


sidebarTools : Tool -> Html Msg
sidebarTools selectedTool =
    div
        [ class "tools" ]
        [ h3 [] [ text "Tools" ]
        , ul [ class "buttons" ] <|
            List.map (sidebarTool selectedTool) tools
        ]


sidebarMouse : MouseModel -> Html Msg
sidebarMouse mouse =
    div []
        [ h3 [] [ text "Mouse" ]
        , dl []
            [ dt [] [ text "Position" ]
            , dd [] [ text <| toString mouse.position ]
            , dt [] [ text "Down?" ]
            , dd [] [ text <| toString mouse.down ]
            , dt [] [ text "SVG Position" ]
            , dd [] [ text <| toString mouse.svgPosition ]
            ]
        ]


shapeActions : List ( ShapeAction, Html Msg )
shapeActions =
    [ ( SendToBack, icon "fast-backward" )
    , ( SendBackward, icon "backward" )
    , ( BringForward, icon "forward" )
    , ( BringToFront, icon "fast-forward" )
    ]


sidebarSelectedShapeAction : ( ShapeAction, Html Msg ) -> Html Msg
sidebarSelectedShapeAction ( shapeAction, icon ) =
    li
        [ onClick <| SelectedShapeAction shapeAction
        ]
        [ icon ]


sidebarSelectedShapeActions : Maybe Int -> Dict Int Shape -> Html Msg
sidebarSelectedShapeActions maybeSelectedShapeId shapes =
    case maybeSelectedShapeId of
        Nothing ->
            text ""

        Just selectedShapeId ->
            case Dict.get selectedShapeId shapes of
                Nothing ->
                    text ""

                Just selectedShape ->
                    div []
                        [ h3 [] [ text "Actions" ]
                        , ul [ class "buttons actions" ] <|
                            List.map sidebarSelectedShapeAction shapeActions
                        ]


sidebar : Maybe Int -> Dict Int Shape -> MouseModel -> Tool -> Html Msg
sidebar maybeSelectedShapeId shapes mouse selectedTool =
    section
        [ class <| "sidebar " ++ Pure.unit [ "1", "8" ] ]
        [ sidebarTools selectedTool
        , sidebarSelectedShapeActions maybeSelectedShapeId shapes
        , sidebarMouse mouse
        ]


onDrawingAreaClick : Tool -> MouseModel -> Msg
onDrawingAreaClick tool mouse =
    case tool of
        PointerTool ->
            DeselectShape

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


onPreventingDefault : String -> Msg -> Svg.Attribute Msg
onPreventingDefault event msg =
    onWithOptions
        event
        { preventDefault = False
        , stopPropagation = True
        }
        (Decode.succeed <| msg)


onMouseDownPreventingDefault : Msg -> Svg.Attribute Msg
onMouseDownPreventingDefault msg =
    onPreventingDefault "mousedown" msg


onClickPreventingDefault : Msg -> Svg.Attribute Msg
onClickPreventingDefault msg =
    onPreventingDefault "click" msg


dragHandleWidth : Int
dragHandleWidth =
    20


dragHandle : ( Float, Float ) -> Svg Msg
dragHandle ( x_, y_ ) =
    rect
        [ x <| toString x_
        , y <| toString y_
        , width (toString dragHandleWidth)
        , height (toString dragHandleWidth)
        , stroke "yellow"
        , strokeWidth "2"
        , strokeDasharray "4,4"
        , fill "transparent"
        , SA.class "selection-drag-handle"
        , onMouseDownPreventingDefault <| BeginDrag DragResize
        , onClickPreventingDefault <| NoOp
        ]
        []


{-| make a FontAwesome icon from a string
-}
icon : String -> Html.Html msg
icon s =
    Html.i [ class <| fontClass s ] []


{-| Take raw FontAwesome class string and prepend with fa class
-}
fontClass : String -> String
fontClass s =
    "fa fa-" ++ s
