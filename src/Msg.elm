module Msg
    exposing
        ( Msg(..)
        , ModifyShapeMsg(..)
        , ShapeAction(..)
        , TextAction(..)
        , RectAction(..)
        )

import Model exposing (Shape(..), Tool(..), SvgPosition)
import Mouse
import Drag exposing (DragAction)
import Json.Encode exposing (Value)
import ContextMenu


type Msg
    = NoOp
    | MouseMove Mouse.Position
    | MouseDown Mouse.Position
    | MouseUp Mouse.Position
    | DeselectShape
    | SelectShape Int
    | AddShape Shape
    | RemoveShape Int
    | SelectTool Tool
    | MouseSvgMove SvgPosition
    | BeginDrag DragAction
    | EndDrag
    | SelectedShapeAction ShapeAction
    | ReceiveShapes Value
    | RequestAuthentication
    | ReceiveUser Value
    | LogOut
    | BeginImageUpload SvgPosition
    | CancelImageUpload
    | StoreFile String
    | ReceiveFileStorageUpdate Value
    | ContextMenuMsg (ContextMenu.Msg Int)


type ShapeAction
    = SendToBack
    | SendBackward
    | BringForward
    | BringToFront
    | UpdateText TextAction
    | UpdateRect RectAction


type TextAction
    = SetContent String


type RectAction
    = SetRectX Float
    | SetRectY Float
    | SetRectWidth Float
    | SetRectHeight Float
    | SetRectFill String
    | SetRectStroke String


type ModifyShapeMsg
    = IncreaseWidth Float
