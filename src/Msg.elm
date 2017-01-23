module Msg exposing (Msg(..), ModifyShapeMsg(..))

import Model exposing (Shape(..), Tool(..), SvgPosition)
import Mouse
import Drag exposing (DragAction)


type Msg
    = NoOp
    | MouseMove Mouse.Position
    | MouseDown Mouse.Position
    | MouseUp Mouse.Position
    | ModifyShape Int ModifyShapeMsg
    | SelectShape Int
    | AddShape Shape
    | SelectTool Tool
    | MouseSvgMove SvgPosition
    | BeginDrag DragAction
    | EndDrag


type ModifyShapeMsg
    = IncreaseWidth Float
