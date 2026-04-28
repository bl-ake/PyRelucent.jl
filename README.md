# PyRelucent

[![Build Status](https://github.com/bl-ake/PyRelucent.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/bl-ake/PyRelucent.jl/actions/workflows/CI.yml?query=branch%3Amain)

Julia wrapper for the Python package [`relucent`](https://github.com/bl-ake/relucent).

## Design

- Julia uses `PythonCall.jl` to expose a thin wrapper around relucent's public API.
- At module init, `relucent` is installed with `pip` in the active PythonCall interpreter if not already present.
- A local bootstrap fingerprint avoids reinstalling when the Python interpreter and install inputs are unchanged.

## Versioning

`PyRelucent.jl` mirrors the version of the upstream Python [`relucent`](https://github.com/bl-ake/relucent) package. A given `PyRelucent` version `x.y.z` wraps `relucent x.y.z` and exposes the same public API.

## Usage

Networks are specified as a list of `(weight, bias)` pairs, where each weight is a `Matrix` with shape `(out, in)` and each bias is a `Vector` of length `out`.

```julia
using PyRelucent

# Define a 2 → 10 → 5 → 1 network with random weights
W1, b1 = randn(10, 2), randn(10)
W2, b2 = randn(5, 10), randn(5)
W3, b3 = randn(1,  5), randn(1)

# Initialize a Complex to track activation regions
cplx = PyRelucent.Complex([(W1, b1), (W2, b2), (W3, b3)])

# Discover activation regions via local search
cplx.bfs()

# Plotting functions return Plotly figures
fig = cplx.plot()
fig.show()

input_point = randn(1, 2)
p = cplx.point2poly(input_point)

println(p.halfspaces[p.shis])
println(sum(length(poly.shis) for poly in cplx) / length(cplx))
println(cplx.get_dual_graph())
```

Use `PyRelucent.pyrelucent()` if you need direct access to the Python module.
