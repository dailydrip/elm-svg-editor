module Msg
    exposing
        ( Msg(..)
        , ModifyShapeMsg(..)
        , ShapeAction(..)
        , TextAction(..)
        )

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
    | Text TextAction


type TextAction
    = SetContent String


type ModifyShapeMsg
    = IncreaseWidth Float
