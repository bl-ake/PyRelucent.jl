using PyRelucent
using Test

@testset "PyRelucent.jl" begin
    @testset "Smoke test" begin
        @test !isempty(PyRelucent.version())

        cplx = PyRelucent.Complex([(randn(4, 2), randn(4)), (randn(1, 4), randn(1))])
        @test length(cplx) >= 0
    end

    @testset "README starter code" begin
        cplx = PyRelucent.Complex([
            (randn(10, 2), randn(10)),
            (randn(5, 10), randn(5)),
            (randn(1,  5), randn(1)),
        ])
        cplx.bfs()

        fig = cplx.plot()
        @test length(cplx) > 0

        p = cplx.point2poly(randn(1, 2))
        _ = p.halfspaces[p.shis]
        _ = p.center
        _ = p.inradius
        _ = cplx.get_dual_graph()
        @test true
    end

    @testset "README" begin
        W1, b1 = randn(10, 2), randn(10)
        W2, b2 = randn(5, 10), randn(5)
        W3, b3 = randn(1,  5), randn(1)

        cplx = PyRelucent.Complex([(W1, b1), (W2, b2), (W3, b3)])
        cplx.bfs()

        fig = cplx.plot()
        @test length(cplx) > 0

        input_point = randn(1, 2)
        p = cplx.point2poly(input_point)

        println(p.halfspaces[p.shis])
        println(sum(length(poly.shis) for poly in cplx) / length(cplx))
        println(cplx.get_dual_graph())
        @test true
    end
end
