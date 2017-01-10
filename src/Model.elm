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


type alias Model =
    { mouse : MouseModel
    }


type alias MouseModel =
    { position : Mouse.Position
    , down : Bool
    }


type Shape
    = Rect RectModel
    | Circle CircleModel


type alias RectModel =
    { x : String
    , y : String
    , width : String
    , height : String
    , stroke : String
    , fill : String
    }


type alias CircleModel =
    { cx : String
    , cy : String
    , r : String
    , stroke : String
    , fill : String
    }


initialModel : Model
initialModel =
    Model <|
        MouseModel { x = 0, y = 0 } False
