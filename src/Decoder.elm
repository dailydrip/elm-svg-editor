module Decoder exposing (shapesDecoder, userDecoder, uploadDecoder)

import Json.Decode exposing (..)
import Json.Decode.Pipeline
    exposing
        ( decode
        , required
        , custom
        )
import Model
    exposing
        ( Shape(..)
        , RectModel
        , CircleModel
        , TextModel
        , User
        , Upload(..)
        , ImageUpload(..)
        )
import Dict exposing (Dict)


shapesDecoder : Decoder (Dict Int Shape)
shapesDecoder =
    dict shapeDecoder
        |> map parseIntKeys


parseIntKeys : Dict String Shape -> Dict Int Shape
parseIntKeys stringShapes =
    stringShapes
        |> Dict.toList
        |> List.map
            (\( k, v ) ->
                ( k |> String.toInt |> Result.withDefault 0
                , v
                )
            )
        |> Dict.fromList


shapeDecoder : Decoder Shape
shapeDecoder =
    field "type" string
        |> andThen specificShapeDecoder


specificShapeDecoder : String -> Decoder Shape
specificShapeDecoder typeStr =
    case typeStr of
        "rect" ->
            decode Rect
                |> custom rectModelDecoder

        "circle" ->
            decode Circle
                |> custom circleModelDecoder

        "text" ->
            decode Text
                |> custom textModelDecoder

        _ ->
            fail "unknown shape type"


rectModelDecoder : Decoder RectModel
rectModelDecoder =
    decode RectModel
        |> required "x" float
        |> required "y" float
        |> required "width" float
        |> required "height" float
        |> required "stroke" string
        |> required "strokeWidth" float
        |> required "fill" string


circleModelDecoder : Decoder CircleModel
circleModelDecoder =
    decode CircleModel
        |> required "cx" float
        |> required "cy" float
        |> required "r" float
        |> required "stroke" string
        |> required "strokeWidth" float
        |> required "fill" string


textModelDecoder : Decoder TextModel
textModelDecoder =
    decode TextModel
        |> required "x" float
        |> required "y" float
        |> required "content" string
        |> required "fontFamily" string
        |> required "fontSize" int
        |> required "stroke" string
        |> required "strokeWidth" float
        |> required "fill" string


userDecoder : Decoder User
userDecoder =
    decode User
        |> required "displayName" string
        |> required "email" string
        |> required "photoURL" string


uploadDecoder : Decoder Upload
uploadDecoder =
    oneOf <|
        [ field "running" <| map Running float
        , field "error" <| map Errored string
        , field "paused" <| map Paused float
        , field "complete" <| map Completed string
        ]
