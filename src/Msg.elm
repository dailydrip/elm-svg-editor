module Msg exposing (Msg(..), ModifyShapeMsg(..))

import Model exposing (Shape(..), Tool(..), SvgPosition)
import Mouse


type Msg
    = NoOp
    | MouseMove Mouse.Position
    | MouseDown Mouse.Position
    | MouseUp Mouse.Position
    | MouseSvgMove SvgPosition
    | ModifyShape Int ModifyShapeMsg
    | SelectShape Int
    | AddShape Shape
    | SelectTool Tool


type ModifyShapeMsg
    = IncreaseWidth Float
