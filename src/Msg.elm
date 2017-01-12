module Msg exposing (Msg(..), ModifyShapeMsg(..))

import Mouse


type Msg
    = NoOp
    | MouseMove Mouse.Position
    | MouseDown Mouse.Position
    | MouseUp Mouse.Position
    | ModifyShape Int ModifyShapeMsg
    | SelectShape Int


type ModifyShapeMsg
    = IncreaseWidth Float
