module Model
    exposing
        ( Model
        , MouseModel
        , RectModel
        , CircleModel
        , Shape(..)
        , initialModel
        )

import Mouse
import Dict exposing (Dict)


type alias Model =
    { mouse : MouseModel
    , shapes : Dict Int Shape
    , selectedShapeId : Maybe Int
    }


type alias MouseModel =
    { position : Mouse.Position
    , down : Bool
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
    , fill : String
    }


type alias CircleModel =
    { cx : Float
    , cy : Float
    , r : Float
    , stroke : String
    , fill : String
    }


initialModel : Model
initialModel =
    Model
        (MouseModel { x = 0, y = 0 } False)
        initialShapes
        Nothing


initialShapes : Dict Int Shape
initialShapes =
    Dict.empty
        |> Dict.insert 1
            (Rect
                { x = 20
                , y = 20
                , width = 20
                , height = 20
                , stroke = "black"
                , fill = "transparent"
                }
            )
        |> Dict.insert 2
            (Circle
                { cx = 50
                , cy = 20
                , r = 5
                , stroke = "red"
                , fill = "yellow"
                }
            )
