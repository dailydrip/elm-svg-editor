module Update exposing (update)

import Model
    exposing
        ( Model
        , Shape(..)
        , Tool(..)
        , RectModel
        , CircleModel
        , TextModel
        , SvgPosition
        , ImageUpload(..)
        , Upload(..)
        )
import Msg exposing (Msg(..), ShapeAction(..), TextAction(..), RectAction(..))
import Drag exposing (DragAction(..))
import Dict exposing (Dict)
import Encoder exposing (shapesEncoder)
import Ports exposing (persistShapes)
import Json.Decode as Decode
import Decoder exposing (shapesDecoder, userDecoder, uploadDecoder)
import ContextMenu


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
                    { mouse | down = True, downSvgPosition = mouse.svgPosition }
            in
                { model | mouse = nextMouse } ! []

        MouseUp pos ->
            let
                nextMouse =
                    { mouse | down = False }

                nextModel =
                    { model
                        | mouse = nextMouse
                        , dragAction = Nothing
                        , comparedShape = Nothing
                    }
            in
                case model.dragAction of
                    Just _ ->
                        ( nextModel, sendShapes nextModel.shapes )

                    Nothing ->
                        nextModel
                            ! []

        MouseSvgMove pos ->
            let
                nextMouse =
                    { mouse | svgPosition = pos }

                nextModel =
                    handleDrag pos model
            in
                ({ nextModel | mouse = nextMouse } ! [])

        SelectShape shapeId ->
            { model
                | selectedShapeId = Just shapeId
            }
                ! []

        DeselectShape ->
            { model
                | selectedShapeId = Nothing
            }
                ! []

        AddShape shape ->
            ( model |> addShape shape
            , Cmd.none
            )
                |> andSendShapes

        SelectTool tool ->
            { model | selectedTool = tool } ! []

        BeginDrag dragAction ->
            let
                comparedShape =
                    case model.selectedShapeId of
                        Nothing ->
                            Nothing

                        Just shapeId ->
                            Dict.get shapeId model.shapes

                nextMouse =
                    { mouse | downSvgPosition = mouse.svgPosition }
            in
                { model
                    | dragAction = Just dragAction
                    , comparedShape = comparedShape
                    , mouse = nextMouse
                }
                    ! []

        EndDrag ->
            { model
                | dragAction = Nothing
                , comparedShape = Nothing
            }
                ! []

        SelectedShapeAction shapeAction ->
            handleShapeAction shapeAction model
                |> andSendShapes

        ReceiveShapes value ->
            value
                |> Decode.decodeValue shapesDecoder
                |> Result.map (\shapes -> { model | shapes = shapes } ! [])
                |> Result.withDefault (model ! [])

        RequestAuthentication ->
            model ! [ Ports.requestAuthentication () ]

        ReceiveUser value ->
            value
                |> Decode.decodeValue userDecoder
                |> Debug.log "decode user"
                |> Result.map (\user -> { model | user = Just user } ! [])
                |> Result.withDefault (model ! [])

        LogOut ->
            { model | user = Nothing } ! [ Ports.logOut () ]

        -- We need to handle a message that signals we'll start the image upload
        -- UI process
        BeginImageUpload svgPosition ->
            { model | imageUpload = Just (AwaitingFileSelection svgPosition) }
                ! []

        -- We have to support canceling the process
        CancelImageUpload ->
            { model | imageUpload = Nothing } ! []

        -- When we ask to store a file, if we're in the right state, we'll
        -- transition to the `AwaitingCompletion` state, say we're Running with
        -- 0% complete, and tell the JavaScript to store the file at our DOM
        -- node
        StoreFile id ->
            case model.imageUpload of
                Just (AwaitingFileSelection svgPosition) ->
                    { model | imageUpload = Just (AwaitingCompletion svgPosition (Running 0)) } ! [ Ports.storeFile id ]

                _ ->
                    model ! []

        -- When we get updates on the status, we'll handle the inbound
        -- information only if we're waiting to hear about it. We'll also
        -- pattern match out the svg position so we can ultimately place the
        -- uploaded image in the correct position when it completes uploading
        ReceiveFileStorageUpdate value ->
            case model.imageUpload of
                Just (AwaitingCompletion svgPosition _) ->
                    handleImageUpload model svgPosition value ! []

                _ ->
                    model ! []

        ContextMenuMsg cMsg ->
            let
                ( contextMenu, cmd ) =
                    ContextMenu.update cMsg model.contextMenu
            in
                { model | contextMenu = contextMenu } ! [ Cmd.map ContextMenuMsg cmd ]



-- Handling the upload consists of decoding the information we're passed and
-- updating the `imageUpload` field in the model


handleImageUpload : Model -> SvgPosition -> Decode.Value -> Model
handleImageUpload model svgPosition value =
    let
        -- We'll use the `uploadDecoder` to decode the value
        uploadResult =
            Decode.decodeValue uploadDecoder (Debug.log "val" value)
    in
        case uploadResult of
            -- if it successfully decodes...
            Ok upload ->
                -- We'll look at its state
                case upload of
                    -- If it's a complete upload, we'll just notify ourselves in
                    -- the console for now and cancel the imageUpload
                    Completed fileUrl ->
                        let
                            _ =
                                Debug.log "image is available at" fileUrl

                            imageShape =
                                Image
                                    { x = svgPosition.x
                                    , y = svgPosition.y
                                    , width = 100
                                    , height = 100
                                    , href = fileUrl
                                    }

                            nextModel =
                                addShape imageShape model
                        in
                            { nextModel | imageUpload = Nothing }

                    -- Otherwise, we'll update the imageUpload with the upload
                    -- state
                    u ->
                        { model | imageUpload = Just (AwaitingCompletion svgPosition u) }

            -- And if there was an error, we'll print it to the console for now
            Err error ->
                let
                    _ =
                        Debug.log "error decoding upload" error
                in
                    model


handleShapeAction : ShapeAction -> Model -> ( Model, Cmd Msg )
handleShapeAction shapeAction ({ selectedShapeId, shapeOrdering } as model) =
    case shapeAction of
        SendToBack ->
            { model
                | shapeOrdering = sendShapeToBack selectedShapeId shapeOrdering
            }
                ! []

        SendBackward ->
            { model
                | shapeOrdering = sendShapeBackward selectedShapeId shapeOrdering
            }
                ! []

        BringForward ->
            { model
                | shapeOrdering = bringShapeForward selectedShapeId shapeOrdering
            }
                ! []

        BringToFront ->
            { model
                | shapeOrdering = bringShapeToFront selectedShapeId shapeOrdering
            }
                ! []

        UpdateText textAction ->
            { model | shapes = updateTextShape textAction selectedShapeId model.shapes }
                ! []

        UpdateRect rectAction ->
            { model | shapes = updateRectShape rectAction selectedShapeId model.shapes }
                ! []


updateRectShape : RectAction -> Maybe Int -> Dict Int Shape -> Dict Int Shape
updateRectShape rectAction maybeSelectedShapeId shapes =
    case maybeSelectedShapeId of
        Nothing ->
            shapes

        Just selectedShapeId ->
            case Dict.get selectedShapeId shapes of
                Nothing ->
                    shapes

                Just shape ->
                    case shape of
                        Rect rectModel ->
                            Dict.insert selectedShapeId
                                (Rect <|
                                    handleRectAction
                                        rectAction
                                        rectModel
                                )
                                shapes

                        _ ->
                            shapes


handleRectAction : RectAction -> RectModel -> RectModel
handleRectAction rectAction rectModel =
    case rectAction of
        SetRectX x ->
            { rectModel | x = x }

        SetRectY y ->
            { rectModel | y = y }

        SetRectWidth width ->
            { rectModel | width = width }

        SetRectHeight height ->
            { rectModel | height = height }

        SetRectFill fill ->
            { rectModel | fill = fill }

        SetRectStroke stroke ->
            { rectModel | stroke = stroke }


updateTextShape : TextAction -> Maybe Int -> Dict Int Shape -> Dict Int Shape
updateTextShape textAction maybeSelectedShapeId shapes =
    case maybeSelectedShapeId of
        Nothing ->
            shapes

        Just selectedShapeId ->
            case Dict.get selectedShapeId shapes of
                Nothing ->
                    shapes

                Just shape ->
                    case shape of
                        Model.Text textModel ->
                            Dict.insert selectedShapeId
                                (Model.Text <|
                                    handleTextAction
                                        textAction
                                        textModel
                                )
                                shapes

                        _ ->
                            shapes


handleTextAction : TextAction -> TextModel -> TextModel
handleTextAction textAction textModel =
    case textAction of
        SetContent content ->
            { textModel | content = content }


existingOrder : Int -> Dict Int Int -> Int
existingOrder shapeId shapeOrdering =
    shapeOrdering
        |> Dict.get shapeId
        |> Maybe.withDefault 0


sendShapeBackward : Maybe Int -> Dict Int Int -> Dict Int Int
sendShapeBackward maybeSelectedShapeId shapeOrdering =
    case maybeSelectedShapeId of
        Nothing ->
            shapeOrdering

        Just shapeId ->
            Dict.insert shapeId ((existingOrder shapeId shapeOrdering) - 1) shapeOrdering


bringShapeForward : Maybe Int -> Dict Int Int -> Dict Int Int
bringShapeForward maybeSelectedShapeId shapeOrdering =
    case maybeSelectedShapeId of
        Nothing ->
            shapeOrdering

        Just shapeId ->
            Dict.insert shapeId ((existingOrder shapeId shapeOrdering) + 1) shapeOrdering


sendShapeToBack : Maybe Int -> Dict Int Int -> Dict Int Int
sendShapeToBack maybeSelectedShapeId shapeOrdering =
    case maybeSelectedShapeId of
        Nothing ->
            shapeOrdering

        Just shapeId ->
            let
                lowestOrder : Int
                lowestOrder =
                    shapeOrdering
                        |> Dict.remove shapeId
                        |> Dict.values
                        |> List.minimum
                        |> Maybe.withDefault 0
            in
                Dict.insert shapeId (lowestOrder - 1) shapeOrdering


bringShapeToFront : Maybe Int -> Dict Int Int -> Dict Int Int
bringShapeToFront maybeSelectedShapeId shapeOrdering =
    case maybeSelectedShapeId of
        Nothing ->
            shapeOrdering

        Just shapeId ->
            let
                highestOrder : Int
                highestOrder =
                    shapeOrdering
                        |> Dict.remove shapeId
                        |> Dict.values
                        |> List.maximum
                        |> Maybe.withDefault 0
            in
                Dict.insert shapeId (highestOrder + 1) shapeOrdering


handleDrag : SvgPosition -> Model -> Model
handleDrag pos model =
    case model.dragAction of
        Nothing ->
            model

        Just dragAction ->
            case model.selectedShapeId of
                Nothing ->
                    model

                Just shapeId ->
                    case model.comparedShape of
                        Nothing ->
                            model

                        Just shape ->
                            handleDragAction dragAction shapeId shape pos model


handleDragAction : DragAction -> Int -> Shape -> SvgPosition -> Model -> Model
handleDragAction dragAction shapeId shape pos ({ mouse } as model) =
    let
        newShape : Shape
        newShape =
            case dragAction of
                DragMove ->
                    let
                        dragDiffX =
                            mouse.downSvgPosition.x - mouse.svgPosition.x

                        dragDiffY =
                            mouse.downSvgPosition.y - mouse.svgPosition.y
                    in
                        case shape of
                            Rect rectModel ->
                                Rect
                                    { rectModel
                                        | x = rectModel.x - dragDiffX
                                        , y = rectModel.y - dragDiffY
                                    }

                            Circle circleModel ->
                                Circle
                                    { circleModel
                                        | cx = circleModel.cx - dragDiffX
                                        , cy = circleModel.cy - dragDiffY
                                    }

                            Model.Text textModel ->
                                Model.Text
                                    { textModel
                                        | x = textModel.x - dragDiffX
                                        , y = textModel.y - dragDiffY
                                    }

                            Image imageModel ->
                                Image
                                    { imageModel
                                        | x = imageModel.x - dragDiffX
                                        , y = imageModel.y - dragDiffY
                                    }

                DragResize ->
                    case ( shape, model.comparedShape ) of
                        ( Rect rectModel, Just (Rect compRect) ) ->
                            let
                                ( newX, newWidth ) =
                                    if pos.x <= compRect.x then
                                        ( pos.x, compRect.x - pos.x )
                                    else
                                        ( compRect.x, pos.x - compRect.x )

                                ( newY, newHeight ) =
                                    if pos.y <= compRect.y then
                                        ( pos.y, compRect.y - pos.y )
                                    else
                                        ( compRect.y, pos.y - compRect.y )
                            in
                                Rect
                                    { rectModel
                                        | height = newHeight
                                        , width = newWidth
                                        , x = newX
                                        , y = newY
                                    }

                        ( Circle circleModel, Just (Circle compCircle) ) ->
                            let
                                newRX =
                                    abs (pos.x - circleModel.cx)

                                newRY =
                                    abs (pos.y - circleModel.cy)

                                newR =
                                    max newRX newRY
                            in
                                Circle
                                    { circleModel
                                        | r = newR
                                    }

                        ( Image imageModel, Just (Image compImage) ) ->
                            let
                                ( newX, newWidth ) =
                                    if pos.x <= compImage.x then
                                        ( pos.x, compImage.x - pos.x )
                                    else
                                        ( compImage.x, pos.x - compImage.x )

                                ( newY, newHeight ) =
                                    if pos.y <= compImage.y then
                                        ( pos.y, compImage.y - pos.y )
                                    else
                                        ( compImage.y, pos.y - compImage.y )
                            in
                                Image
                                    { imageModel
                                        | height = newHeight
                                        , width = newWidth
                                        , x = newX
                                        , y = newY
                                    }

                        _ ->
                            shape
    in
        { model
            | shapes =
                Dict.insert shapeId
                    newShape
                    model.shapes
        }


addShape : Shape -> Model -> Model
addShape shape model =
    let
        shapes : Dict Int Shape
        shapes =
            model.shapes

        maxId : Int
        maxId =
            shapes
                |> Dict.keys
                |> List.maximum
                |> Maybe.withDefault 0

        nextShapes : Dict Int Shape
        nextShapes =
            model.shapes
                |> Dict.insert (maxId + 1) shape
    in
        { model | shapes = nextShapes }


sendShapes : Dict Int Shape -> Cmd Msg
sendShapes shapes =
    shapes
        |> shapesEncoder
        |> persistShapes


andSendShapes : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andSendShapes ( model, cmd ) =
    ( model
    , Cmd.batch
        [ cmd
        , sendShapes model.shapes
        ]
    )
