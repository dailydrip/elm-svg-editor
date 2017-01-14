module App exposing (..)

import Model
    exposing
        ( Model
        , Shape(..)
        , Tool(..)
        , initialModel
        , RectModel
        , CircleModel
        )
import Msg exposing (Msg(..), ModifyShapeMsg(..))
import Mouse
import Dict exposing (Dict)
import Ports


init : () -> ( Model, Cmd Msg )
init flags =
    initialModel ! []


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

        MouseSvgMove pos ->
            let
                nextMouse =
                    { mouse | svgPosition = pos }
            in
                { model | mouse = nextMouse } ! []

        ModifyShape shapeId shapeMsg ->
            { model
                | shapes = findAndModifyShape shapeId shapeMsg model.shapes
            }
                ! []

        SelectShape shapeId ->
            { model
                | selectedShapeId = Just shapeId
            }
                ! []

        AddShape shape ->
            ( model |> addShape shape
            , Cmd.none
            )

        SelectTool tool ->
            { model | selectedTool = Just tool } ! []


findAndModifyShape : Int -> ModifyShapeMsg -> Dict Int Shape -> Dict Int Shape
findAndModifyShape shapeId shapeMsg shapes =
    case Debug.log "foo" <| Dict.get shapeId shapes of
        Nothing ->
            shapes

        Just shape ->
            shapes
                |> Dict.insert shapeId (updateShape shapeMsg shape)


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


updateShape : ModifyShapeMsg -> Shape -> Shape
updateShape shapeMsg shape =
    case shape of
        Rect rectModel ->
            Rect <| updateRect shapeMsg rectModel

        Circle circleModel ->
            Circle <| updateCircle shapeMsg circleModel


updateRect : ModifyShapeMsg -> RectModel -> RectModel
updateRect msg model =
    let
        _ =
            Debug.log "updateRect" True
    in
        case msg of
            IncreaseWidth amount ->
                { model | width = model.width + amount }


updateCircle : ModifyShapeMsg -> CircleModel -> CircleModel
updateCircle msg model =
    case msg of
        IncreaseWidth amount ->
            { model | r = model.r + amount }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.moves MouseMove
        , Mouse.downs MouseDown
        , Mouse.ups MouseUp
        , Ports.receiveSvgMouseCoordinates MouseSvgMove
        ]
