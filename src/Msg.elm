module Msg exposing (Msg(..), ModifyShapeMsg(..), ShapeAction(..))

import Model exposing (Shape(..), Tool(..), SvgPosition)
import Mouse
import Drag exposing (DragAction)


type Msg
    = NoOp
    | MouseMove Mouse.Position
    | MouseDown Mouse.Position
    | MouseUp Mouse.Position
    | DeselectShape
    | SelectShape Int
    | AddShape Shape
    | SelectTool Tool
    | MouseSvgMove SvgPosition
    | BeginDrag DragAction
    | EndDrag
    | SelectedShapeAction ShapeAction


type ShapeAction
    = SendToBack
    | SendBackward
    | BringForward
    | BringToFront


type ModifyShapeMsg
    = IncreaseWidth Float
