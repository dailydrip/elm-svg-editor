module Model exposing (Model, MouseModel, initialModel)

import Mouse


type alias Model =
    { mouse : MouseModel
    }


type alias MouseModel =
    { position : Mouse.Position
    , down : Bool
    }


initialModel : Model
initialModel =
    Model <|
        MouseModel { x = 0, y = 0 } False
