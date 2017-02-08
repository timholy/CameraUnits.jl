using CameraUnits, Unitful, FixedPointNumbers
using Base.Test

@testset "CameraUnits" begin
    x = 1cu"pco55"
    @test uconvert(γe, x) == 0.46γe
end

nothing
