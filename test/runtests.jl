using Relucent
using PythonCall
using Test

@testset "Relucent.jl" begin
    @testset "Smoke test" begin
        @test !isempty(Relucent.version())

        net = Relucent.mlp(widths=[2, 4, 1], add_last_relu=false)
        @test pytruth(pyhasattr(net, "forward"))

        cplx = Relucent.Complex(net)
        complex_ty = pygetattr(Relucent.pyrelucent(), "Complex")
        @test pytruth(pyisinstance(cplx, complex_ty))
    end

    @testset "README starter code" begin
        np = pyimport("numpy")
        nn = pyimport("torch.nn")

        network = nn.Sequential(
            nn.Linear(2, 10),
            nn.ReLU(),
            nn.Linear(10, 5),
            nn.ReLU(),
            nn.Linear(5, 1),
        )

        cplx = Relucent.Complex(network)
        cplx.bfs()

        fig = cplx.plot()
        @test pytruth(pyhasattr(fig, "show"))
        @test pyconvert(Int, pylen(cplx)) > 0

        input_point = np.random.random((1, 2))
        p = cplx.point2poly(input_point)

        _ = p.halfspaces[p.shis]
        _ = p.center
        _ = p.inradius
        _ = cplx.get_dual_graph()
        @test true
    end
end
