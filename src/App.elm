module App exposing (..)

import Model
    exposing
        ( Model
        , Shape(..)
        , initialModel
        , RectModel
        , CircleModel
        )
import Msg exposing (Msg(..), ModifyShapeMsg(..))
import Mouse
import Dict exposing (Dict)


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

        ModifyShape shapeId shapeMsg ->
            { model
                | shapes = findAndModifyShape shapeId shapeMsg model.shapes
            }
                ! []


findAndModifyShape : Int -> ModifyShapeMsg -> Dict Int Shape -> Dict Int Shape
findAndModifyShape shapeId shapeMsg shapes =
    case Debug.log "foo" <| Dict.get shapeId shapes of
        Nothing ->
            shapes

        Just shape ->
            shapes
                |> Dict.insert shapeId (updateShape shapeMsg shape)


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
        ]
