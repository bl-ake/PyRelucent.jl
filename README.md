# Relucent

[![Build Status](https://github.com/bl-ake/Relucent.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/bl-ake/Relucent.jl/actions/workflows/CI.yml?query=branch%3Amain)

Julia wrapper for the Python package [`relucent`](https://github.com/bl-ake/relucent).

## Design

- The upstream Python repo is vendored as a submodule at `deps/relucent-py`.
- Julia uses `PythonCall.jl` to expose a thin wrapper around relucent's public API.
- At module init, missing dependencies are installed with `pip` in the active PythonCall interpreter:
  - `torch` from the CPU wheel index
  - `relucent` from the submodule path (`pip install -e`)
- A local bootstrap fingerprint avoids reinstalling when the Python interpreter and vendored submodule revision are unchanged.

## Usage

```julia
using Relucent
using PythonCall

np = pyimport("numpy")
nn = pyimport("torch.nn")

# Create Model
network = nn.Sequential(
    nn.Linear(2, 10),
    nn.ReLU(),
    nn.Linear(10, 5),
    nn.ReLU(),
    nn.Linear(5, 1),
)  # or conveniently, Relucent.mlp(widths=[2, 10, 5, 1])

# Initialize a Complex to track calculations
cplx = Relucent.Complex(network)

# Calculate activation regions via local search
cplx.bfs()

# Plotting functions return Plotly figures
fig = cplx.plot()
fig.show()

input_point = np.random.random((1, 2))
p = cplx.point2poly(input_point)

println(p.halfspaces[p.shis])
println(sum(pylen(poly.shis) for poly in cplx) / pylen(cplx))
println(cplx.get_dual_graph())
```

Use `Relucent.pyrelucent()` if you need direct access to the Python module.