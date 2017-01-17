module Msg exposing (Msg(..), ModifyShapeMsg(..))

import Model
    exposing
        ( Shape(..)
        , Tool(..)
        )
import Mouse
import Drag exposing (DragAction)
import SvgPosition exposing (SvgPosition)


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
    | BeginDrag DragAction


type ModifyShapeMsg
    = IncreaseWidth Float
