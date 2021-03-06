import RNG: AbstractRNG

"""
```julia
gen_seed(T[, n])
```

Generate a tuple of `n` truly random numbers in type `T`. If `n` is missing, return only one number.
The "truly" random numbers are provided by the random device of system. See
[`Base.Random.RandomDevice`](https://github.com/JuliaLang/julia/blob/master/base/random.jl#L29).

# Examples
```julia
julia> RNG.gen_seed(UInt64, 2)  # The output should probably be different on different computers.
(0x26aa3fe5e306f725,0x7b9dc3c227d8acc9)

julia> RNG.gen_seed(UInt32)
0x9ba60fdc
```
"""
gen_seed{T<:Number}(::Type{T}) = rand(RandomDevice(), T)
gen_seed{T<:Number}(::Type{T}, n) = tuple(rand(RandomDevice(), T, n)...)

"Get the original output type of a RNG."
@inline output_type{T}(::AbstractRNG{T}) = T

@inline split_uint(x::UInt128) = (x % UInt64, (x >> 64) % UInt64)
@inline split_uint(x::UInt64) = (x % UInt32, (x >> 32) % UInt32)
@inline union_uint(x::NTuple{2, UInt32}) = unsafe_load(Ptr{UInt64}(pointer_from_objref(x)), 1)
@inline union_uint(x::NTuple{2, UInt64}) = unsafe_load(Ptr{UInt128}(pointer_from_objref(x)), 1)
@inline union_uint(x::NTuple{4, UInt32}) = unsafe_load(Ptr{UInt128}(pointer_from_objref(x)), 1)
