module Model
    exposing
        ( Model
        , MouseModel
        , RectModel
        , CircleModel
        , TextModel
        , ImageModel
        , SvgPosition
        , Shape(..)
        , Tool(..)
        , User
        , ImageUpload(..)
        , Upload(..)
        )

import Mouse
import Dict exposing (Dict)
import Drag exposing (DragAction)
import ContextMenu exposing (ContextMenu)


-- We're going to have two cases for an ImageUpload - it's either waiting for a
-- file to be selected (and knows where to put it on the canvas), or it's
-- waiting for the Upload to complete. We'll introduce an `Upload` type to
-- define the states our upload can have.


type ImageUpload
    = AwaitingFileSelection SvgPosition
    | AwaitingCompletion SvgPosition Upload



-- An upload can be running or paused, in which case we want to know how far
-- along it is. It can have errored, in which case we'd like to know the error
-- message. Or it can be completed, in which case we'd like to know the path to
-- the file on Firebase.


type Upload
    = Running Float
    | Paused Float
    | Errored String
    | Completed String


type alias Model =
    { mouse : MouseModel
    , contextMenu : ContextMenu Int
    , shapes : Dict Int Shape
    , shapeOrdering : Dict Int Int
    , selectedShapeId : Maybe Int
    , selectedTool : Tool
    , dragAction : Maybe DragAction
    , comparedShape : Maybe Shape
    , user : Maybe User
    , imageUpload : Maybe ImageUpload
    }


type alias User =
    { displayName : String
    , email : String
    , photoUrl : String
    }


type Tool
    = PointerTool
    | RectTool
    | CircleTool
    | TextTool
    | ImageTool


type alias MouseModel =
    { position : Mouse.Position
    , down : Bool
    , svgPosition : SvgPosition
    , downSvgPosition : SvgPosition
    }


type alias SvgPosition =
    { x : Float
    , y : Float
    }


type Shape
    = Rect RectModel
    | Circle CircleModel
    | Text TextModel
    | Image ImageModel


type alias RectModel =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


type alias CircleModel =
    { cx : Float
    , cy : Float
    , r : Float
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


type alias TextModel =
    { x : Float
    , y : Float
    , content : String
    , fontFamily : String
    , fontSize : Int
    , stroke : String
    , strokeWidth : Float
    , fill : String
    }


type alias ImageModel =
    { x : Float
    , y : Float
    , width : Float
    , height : Float
    , href : String
    }
