port module Ports exposing (receiveSvgMouseCoordinates)

import SvgPosition exposing (SvgPosition)


-- INBOUND PORTS


port receiveSvgMouseCoordinates : (SvgPosition -> msg) -> Sub msg
