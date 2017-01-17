module Model
    exposing
        ( Model
        , MouseModel
        , RectModel
        , CircleModel
        , Shape(..)
        , Tool(..)
        , initialModel
        )

import Mouse
import Dict exposing (Dict)
import SvgPosition exposing (SvgPosition)
import Drag exposing (DragAction)


type alias Model =
    { mouse : MouseModel
    , shapes : Dict Int Shape
    , selectedShapeId : Maybe Int
    , selectedTool : Maybe Tool
    , dragAction : Maybe DragAction
    , comparedShape : Maybe Shape
    }


type alias MouseModel =
    { position : Mouse.Position
    , down : Bool
    , svgPosition : SvgPosition
    , downSvgPosition : SvgPosition
    }


type Shape
    = Rect RectModel
    | Circle CircleModel


type alias RectModel =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


type alias CircleModel =
    { cx : Float
    , cy : Float
    , r : Float
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


type Tool
    = RectTool
    | CircleTool


initialModel : Model
initialModel =
    { mouse = initialMouse
    , shapes = initialShapes
    , selectedShapeId = Nothing
    , selectedTool = Nothing
    , dragAction = Nothing
    , comparedShape = Nothing
    }


initialMouse : MouseModel
initialMouse =
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
                , stroke = "black"
                , strokeWidth = 10
                , fill = "transparent"
                }
            )
        |> Dict.insert 2
            (Circle
                { cx = 500
                , cy = 200
                , r = 50
                , stroke = "red"
                , strokeWidth = 10
                , fill = "yellow"
                }
            )
