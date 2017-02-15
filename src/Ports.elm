port module Ports
    exposing
        ( receiveSvgMouseCoordinates
        , persistShapes
        , receiveShapes
        , requestAuthentication
        , receiveUser
        , logOut
        , storeFile
        , receiveFileStorageUpdate
        )

import Model exposing (SvgPosition)
import Json.Encode exposing (Value)


-- INBOUND PORTS


port receiveSvgMouseCoordinates : (SvgPosition -> msg) -> Sub msg


port receiveShapes : (Value -> msg) -> Sub msg


port receiveUser : (Value -> msg) -> Sub msg


port receiveFileStorageUpdate : (Value -> msg) -> Sub msg



-- OUTBOUND PORTS


port persistShapes : Value -> Cmd msg


port requestAuthentication : () -> Cmd msg


port logOut : () -> Cmd msg


port storeFile : String -> Cmd msg
