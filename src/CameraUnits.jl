__precompile__(true)
module CameraUnits

import Unitful
using Unitful: @unit
using FixedPointNumbers

export γe, @cu_str

@unit γe       "γe"  PhotoElectron      1          false
@unit pco55_cu "cu"  PCO55              0.46γe     false
@unit pco42_cu "cu"  PCO42              0.46γe     false

# Base.convert(N0f16, x::PCO55) = reinterpret(N0f16, round(UInt16, ustrip(x)))
# Base.convert(N0f16, x::PCO42) = reinterpret(N0f16, round(UInt16, ustrip(x)))

include("cumacro.jl")

# Some gymnastics required here because if we precompile, we cannot add to
# Unitful.basefactors at compile time and expect the changes to persist to runtime.
const localunits = Unitful.basefactors
function __init__()
    merge!(Unitful.basefactors, localunits)
    Unitful.register(CameraUnits)
end

end # module
