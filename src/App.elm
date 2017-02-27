module App exposing (..)

import Model exposing (Model, MouseModel, Shape(..), Tool(..))
import Msg exposing (Msg(..))
import Mouse
import Ports
import Dict exposing (Dict)
import ContextMenu


init : () -> ( Model, Cmd Msg )
init flags =
    let
        ( contextMenu, contextMsg ) =
            ContextMenu.init

        model =
            { mouse = initialMouseModel
            , contextMenu = contextMenu
            , shapes = initialShapes
            , shapeOrdering = Dict.empty
            , selectedShapeId = Nothing
            , selectedTool = PointerTool
            , dragAction = Nothing
            , comparedShape = Nothing
            , user = Nothing
            , imageUpload = Nothing
            }
    in
        model ! [ Cmd.map ContextMenuMsg contextMsg ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.moves MouseMove
        , Mouse.downs MouseDown
        , Mouse.ups MouseUp
        , Ports.receiveSvgMouseCoordinates MouseSvgMove
        , Ports.receiveShapes ReceiveShapes
        , Ports.receiveUser ReceiveUser
        , Ports.receiveFileStorageUpdate ReceiveFileStorageUpdate
        , Sub.map ContextMenuMsg (ContextMenu.subscriptions model.contextMenu)
        ]


initialMouseModel : MouseModel
initialMouseModel =
    { position = { x = 0, y = 0 }
    , down = False
    , svgPosition = { x = 0, y = 0 }
    , downSvgPosition = { x = 0, y = 0 }
    }


initialShapes : Dict Int Shape
initialShapes =
    Dict.empty
        |> Dict.insert 1
            (Rect
                { x = 200
                , y = 200
                , width = 200
                , height = 200
                , stroke = "#000000"
                , strokeWidth = 10
                , fill = "#ffffff"
                }
            )
        |> Dict.insert 2
            (Circle
                { cx = 500
                , cy = 200
                , r = 50
                , stroke = "#ff0000"
                , strokeWidth = 10
                , fill = "#00ffff"
                }
            )
