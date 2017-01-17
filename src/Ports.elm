port module Ports exposing (receiveSvgMouseCoordinates)

import Model exposing (SvgPosition)


-- INBOUND PORTS


port receiveSvgMouseCoordinates : (SvgPosition -> msg) -> Sub msg
