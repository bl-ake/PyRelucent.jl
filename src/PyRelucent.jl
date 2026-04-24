module PyRelucent

using PythonCall
using SHA

const _relucent_module = Ref{Py}()

_root_dir() = normpath(joinpath(@__DIR__, ".."))
_python_executable() = pyconvert(String, pyimport("sys").executable)
_importlib_util() = pyimport("importlib.util")
_bootstrap_stamp_path() = joinpath(first(DEPOT_PATH), "relucent", ".relucent-bootstrap-stamp")

function _bootstrap_fingerprint()
    parts = (
        "python=" * _python_executable(),
        "cpu-index=https://download.pytorch.org/whl/cpu",
        "relucent-spec=relucent",
    )
    return bytes2hex(sha1(join(parts, "\n")))
end

function _bootstrap_is_current()
    stamp_path = _bootstrap_stamp_path()
    if !isfile(stamp_path)
        return false
    end
    if !_has_python_module("torch") || !_has_python_module("relucent")
        return false
    end
    try
        return strip(read(stamp_path, String)) == _bootstrap_fingerprint()
    catch
        return false
    end
end

function _write_bootstrap_stamp!()
    stamp_path = _bootstrap_stamp_path()
    mkpath(dirname(stamp_path))
    write(stamp_path, _bootstrap_fingerprint() * "\n")
    return nothing
end

function _has_python_module(name::String)
    spec = pygetattr(_importlib_util(), "find_spec")(name)
    return pytruth(spec != pybuiltins.None)
end

function _pip_install(args::Vector{String})
    python = _python_executable()
    try
        run(Cmd([python, "-m", "pip", "--version"]))
    catch
        run(Cmd([python, "-m", "ensurepip", "--upgrade"]))
    end
    run(Cmd([python, "-m", "pip", "install", args...]))
    return nothing
end

function _ensure_torch_cpu!()
    if !_has_python_module("torch")
        _pip_install(["--index-url", "https://download.pytorch.org/whl/cpu", "torch"])
    end
    return nothing
end

function _ensure_relucent!()
    if !_has_python_module("relucent")
        # Force reinstall to recover from stale editable installs.
        _pip_install(["--upgrade", "--force-reinstall", "relucent"])
    end
    pyimport("importlib").invalidate_caches()
    _relucent_module[] = pyimport("relucent")
    return nothing
end

function __init__()
    # Skip bootstrap when interpreter + install inputs are unchanged.
    if !_bootstrap_is_current()
        _ensure_torch_cpu!()
        _ensure_relucent!()
        # Never fail import just because stamp persistence is unavailable.
        try
            _write_bootstrap_stamp!()
        catch
        end
    else
        _relucent_module[] = pyimport("relucent")
    end
    return nothing
end

"""
    pyrelucent() -> PythonCall.Py

Return the underlying Python `relucent` module object.
"""
function pyrelucent()
    if !isassigned(_relucent_module)
        _relucent_module[] = pyimport("relucent")
    end
    return _relucent_module[]
end

"""
    version() -> String

Return the Python package version exposed by `relucent.__version__`.
"""
version() = string(pygetattr(pyrelucent(), "__version__"))

const Complex = (args...; kwargs...) -> pygetattr(pyrelucent(), "Complex")(args...; kwargs...)
const Polyhedron = (args...; kwargs...) -> pygetattr(pyrelucent(), "Polyhedron")(args...; kwargs...)
const SSManager = (args...; kwargs...) -> pygetattr(pyrelucent(), "SSManager")(args...; kwargs...)
const convert = (args...; kwargs...) -> pygetattr(pyrelucent(), "convert")(args...; kwargs...)
const get_env = (args...; kwargs...) -> pygetattr(pyrelucent(), "get_env")(args...; kwargs...)
const mlp = (args...; kwargs...) -> pygetattr(pyrelucent(), "mlp")(args...; kwargs...)
const set_seeds = (args...; kwargs...) -> pygetattr(pyrelucent(), "set_seeds")(args...; kwargs...)
const split_sequential = (args...; kwargs...) -> pygetattr(pyrelucent(), "split_sequential")(args...; kwargs...)
const get_colors = (args...; kwargs...) -> pygetattr(pyrelucent(), "get_colors")(args...; kwargs...)
const plot_complex = (args...; kwargs...) -> pygetattr(pyrelucent(), "plot_complex")(args...; kwargs...)
const plot_polyhedron = (args...; kwargs...) -> pygetattr(pyrelucent(), "plot_polyhedron")(args...; kwargs...)

export pyrelucent,
    version,
    Complex,
    Polyhedron,
    SSManager,
    convert,
    get_env,
    mlp,
    set_seeds,
    split_sequential,
    get_colors,
    plot_complex,
    plot_polyhedron

end
