module Model
    exposing
        ( Model
        , MouseModel
        , RectModel
        , CircleModel
        , Shape(..)
        , Tool(..)
        , SvgPosition
        , initialModel
        )

import Mouse
import Dict exposing (Dict)


type alias Model =
    { mouse : MouseModel
    , shapes : Dict Int Shape
    , selectedShapeId : Maybe Int
    , selectedTool : Maybe Tool
    }


type alias MouseModel =
    { position : Mouse.Position
    , down : Bool
    , svgPosition : SvgPosition
    }


type alias SvgPosition =
    { x : Float
    , y : Float
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
    Model
        (MouseModel { x = 0, y = 0 } False { x = 0, y = 0 })
        initialShapes
        Nothing
        Nothing


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
