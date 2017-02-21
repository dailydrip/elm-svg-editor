module View exposing (view)

import Html
    exposing
        ( Html
        , a
        , button
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
        , label
        , input
        , progress
        )
import FontAwesome.Web as Icon
import Html.Attributes
    exposing
        ( class
        , href
        , classList
        , value
        , type_
        , attribute
        , id
        )
import Html.Events exposing (onInput, on)
import Pure
import Model
    exposing
        ( Model
        , MouseModel
        , RectModel
        , CircleModel
        , TextModel
        , ImageModel
        , Shape(..)
        , Tool(..)
        , ImageUpload(..)
        , Upload(..)
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
            , BeginImageUpload
            , CancelImageUpload
            , StoreFile
            )
        , ShapeAction(..)
        , TextAction(..)
        , RectAction(..)
        )
import Svg exposing (Svg, svg, rect, circle, g, image)
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
        , xlinkHref
        )
import Svg.Events exposing (onClick)
import Html.Events exposing (onWithOptions)
import Dict exposing (Dict)
import Drag exposing (DragAction(..))
import Json.Decode as Decode


view : Model -> Html Msg
view model =
    let
        drawingAreaOrImageUpload =
            case model.imageUpload of
                Nothing ->
                    drawingArea
                        model.selectedShapeId
                        model.shapes
                        model.selectedTool
                        model.mouse
                        model.shapeOrdering

                Just imageUpload ->
                    imageUploadView imageUpload
    in
        div []
            [ header
                []
                [ h1 [] [ text "Elm SVG Editor" ]
                , p []
                    [ text "from "
                    , a [ href "https://www.dailydrip.com" ] [ text "DailyDrip" ]
                    ]
                , authenticationSection model
                ]
            , div
                [ class Pure.grid ]
                [ sidebar model.selectedShapeId model.shapes model.mouse model.selectedTool
                , drawingAreaOrImageUpload
                ]
            ]


imageUploadView : ImageUpload -> Html Msg
imageUploadView imageUpload =
    let
        contents =
            case imageUpload of
                AwaitingFileSelection _ ->
                    [ input
                        [ type_ "file"
                        , id "imageUpload"
                        , on "change" <|
                            Decode.succeed <|
                                StoreFile "imageUpload"
                        ]
                        []
                    , button
                        [ onClick CancelImageUpload ]
                        [ text "Cancel" ]
                    ]

                AwaitingCompletion _ upload ->
                    case upload of
                        Running p ->
                            [ progress
                                [ value (toString p)
                                , Html.Attributes.max "100"
                                ]
                                []
                            ]

                        Paused p ->
                            [ progress
                                [ value (toString p)
                                , Html.Attributes.max "100"
                                ]
                                []
                            , text "(paused)"
                            ]

                        Errored error ->
                            [ text <|
                                "error: "
                                    ++ error
                            ]

                        Completed _ ->
                            [ text "completed but you should never see me"
                            ]
    in
        section
            [ class <| "drawing-area " ++ Pure.unit [ "7", "8" ] ]
            contents


authenticationSection : Model -> Html Msg
authenticationSection model =
    case model.user of
        Nothing ->
            button
                [ class Pure.button
                , Html.Events.onClick <| Msg.RequestAuthentication
                ]
                [ text "Log in" ]

        Just user ->
            Html.span []
                [ p [] [ text user.displayName ]
                , button
                    [ class Pure.button
                    , Html.Events.onClick <| Msg.LogOut
                    ]
                    [ text "Log out" ]
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

            Model.Text textModel ->
                viewText selectedTool selected shapeId textModel

            Image imageModel ->
                viewImage selectedTool
                    selected
                    shapeId
                    imageModel


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


viewText : Tool -> Bool -> Int -> TextModel -> Svg Msg
viewText selectedTool selected shapeId textModel =
    if selected then
        g []
            [ viewUnselectedText selectedTool shapeId textModel
            , viewSelectedText selectedTool shapeId textModel
            ]
    else
        viewUnselectedText selectedTool shapeId textModel


viewSelectedText : Tool -> Int -> TextModel -> Svg Msg
viewSelectedText selectedTool shapeId textModel =
    Svg.text_
        ([ x (toString textModel.x)
         , y (toString textModel.y)
         ]
            ++ selectionAttributes selectedTool
        )
        [ Svg.text textModel.content ]


viewUnselectedText : Tool -> Int -> TextModel -> Svg Msg
viewUnselectedText selectedTool shapeId textModel =
    Svg.text_
        ([ x (toString textModel.x)
         , y (toString textModel.y)
         , stroke textModel.stroke
         , strokeWidth (toString textModel.strokeWidth)
         , fill textModel.fill
         ]
            ++ (onShapeClick selectedTool shapeId)
        )
        [ Svg.text textModel.content ]


viewImage : Tool -> Bool -> Int -> ImageModel -> Svg Msg
viewImage selectedTool selected shapeId imageModel =
    let
        imageSelection =
            rect
                ([ x (toString imageModel.x)
                 , y (toString imageModel.y)
                 , width (toString imageModel.width)
                 , height (toString imageModel.height)
                 ]
                    ++ (selectionAttributes selectedTool)
                )
                []

        groupChildren =
            if selected then
                [ viewUnselectedImage selectedTool shapeId imageModel
                , imageSelection
                , dragHandle
                    ( imageModel.x + imageModel.width
                    , imageModel.y + imageModel.height
                    )
                ]
            else
                [ viewUnselectedImage selectedTool shapeId imageModel ]
    in
        g [] groupChildren


viewUnselectedImage : Tool -> Int -> ImageModel -> Svg Msg
viewUnselectedImage selectedTool shapeId imageModel =
    image
        ([ x (toString imageModel.x)
         , y (toString imageModel.y)
         , width (toString imageModel.width)
         , height (toString imageModel.height)
         , xlinkHref imageModel.href
         , preserveAspectRatio "none"
         ]
            ++ (onShapeClick selectedTool shapeId)
        )
        []


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
    , ( TextTool, icon "font" )
    , ( ImageTool, Icon.picture_o )
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
        , sidebarSelectedShapeForm maybeSelectedShapeId shapes
        , sidebarMouse mouse
        ]


sidebarSelectedShapeForm : Maybe Int -> Dict Int Shape -> Html Msg
sidebarSelectedShapeForm maybeSelectedShapeId shapes =
    case maybeSelectedShapeId of
        Nothing ->
            text ""

        Just selectedShapeId ->
            case Dict.get selectedShapeId shapes of
                Nothing ->
                    text ""

                Just selectedShape ->
                    case selectedShape of
                        Model.Text textModel ->
                            textForm textModel

                        Rect rectModel ->
                            rectForm rectModel

                        _ ->
                            text ""


textForm : TextModel -> Html Msg
textForm textModel =
    Html.input
        [ value textModel.content
        , onInput <|
            SelectedShapeAction
                << UpdateText
                << SetContent
        ]
        []


rectForm : RectModel -> Html Msg
rectForm rectModel =
    let
        updateFloat : (Float -> RectAction) -> String -> Msg
        updateFloat tagger input =
            case String.toFloat input of
                Ok val ->
                    SelectedShapeAction <|
                        UpdateRect <|
                            (tagger val)

                Err _ ->
                    NoOp
    in
        div []
            [ label [] [ text "x" ]
            , input
                [ type_ "number"
                , value <| toString rectModel.x
                , onInput <| updateFloat SetRectX
                ]
                []
            , label [] [ text "y" ]
            , input
                [ type_ "number"
                , value <| toString rectModel.y
                , onInput <| updateFloat SetRectY
                ]
                []
            , label [] [ text "width" ]
            , input
                [ type_ "number"
                , attribute "min" "0"
                , value <| toString rectModel.width
                , onInput <| updateFloat SetRectWidth
                ]
                []
            , label [] [ text "height" ]
            , input
                [ type_ "number"
                , attribute "min" "0"
                , value <| toString rectModel.height
                , onInput <| updateFloat SetRectHeight
                ]
                []
            , label [] [ text "stroke" ]
            , input
                [ type_ "color"
                , value rectModel.stroke
                , onInput <| SelectedShapeAction << UpdateRect << SetRectStroke
                ]
                []
            , label [] [ text "fill" ]
            , input
                [ type_ "color"
                , value rectModel.fill
                , onInput <| SelectedShapeAction << UpdateRect << SetRectFill
                ]
                []
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
                    , stroke = "#00ffff"
                    , strokeWidth = 10
                    , fill = "#ff0000"
                    }
                )

        TextTool ->
            AddShape <|
                (Model.Text
                    { x = mouse.svgPosition.x
                    , y = mouse.svgPosition.y
                    , content = "Text"
                    , fill = "#000000"
                    , fontFamily = "Arial"
                    , fontSize = 12
                    , stroke = "transparent"
                    , strokeWidth = 0
                    }
                )

        ImageTool ->
            BeginImageUpload mouse.svgPosition


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
