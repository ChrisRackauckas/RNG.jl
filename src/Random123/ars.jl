import RNG: gen_seed

"""
```julia
ARS1x{R} <: R123Generator1x{UInt128}
ARS1x([seed, R=7])
```

ARS1x is one kind of ARS Counter-Based RNGs. It generates one `UInt128` number at a time.

`seed` is an `Integer` which will be automatically converted to `UInt128`.

`R` denotes to the Rounds which should be at least 1 and no more than 10. With 7 rounds (by default), it has
a considerable safety margin over the minimum number of rounds with no known statistical flaws, but still has
excellent performance.

Only available when [`R123_USE_AESNI`](@ref).
"""
type ARS1x{R} <: R123Generator1x{UInt128}
    x::UInt128
    key::UInt128
    ctr::UInt128
end

function ARS1x(seed::Integer=gen_seed(UInt128), R::Integer=7)
    @assert 1 <= R <= 10
    r = ARS1x{Int(R)}(0, 0, 0)
    srand(r, seed)
end

function srand(r::ARS1x, seed::Integer=gen_seed(UInt128))
    r.key = seed % UInt128
    r.ctr = 0
    random123_r(r)
    r
end

for R = 1:10
    @eval @inline function ars1xm128i(r, ::Type{Val{$R}}, ctr, key)
        p1 = Ptr{UInt128}(pointer_from_objref(ctr))
        p2 = Ptr{UInt128}(pointer_from_objref(key))
        p = Ptr{UInt128}(pointer_from_objref(r))
        ccall(($("ars1xm128i$R"), librandom123), Void, (
        Ptr{UInt128}, Ptr{UInt128}, Ptr{UInt128}
        ), p1, p2, p)
        unsafe_load(p, 1)
    end
end

@inline function random123_r{R}(r::ARS1x{R})
    ars1xm128i(r, Val{R}, r.ctr, r.key)
    (r.x,)
end

"""
```julia
ARS4x{R} <: R123Generator4x{UInt32}
ARS4x([seed, R=7])
```

ARS4x is one kind of ARS Counter-Based RNGs. It generates four `UInt32` numbers at a time.

`seed` is a `Tuple` of four `Integer`s which will all be automatically converted to `UInt32`.

`R` denotes to the Rounds which must be at least 1 and no more than 10. With 7 rounds (by default), it has a
considerable safety margin over the minimum number of rounds with no known statistical flaws, but still has
excellent performance.

Only available when [`R123_USE_AESNI`](@ref).
"""
type ARS4x{R} <: R123Generator4x{UInt32}
    x1::UInt32
    x2::UInt32
    x3::UInt32
    x4::UInt32
    key::UInt128
    ctr1::UInt128
    p::Int
end

function ARS4x(seed::NTuple{4, Integer}=gen_seed(UInt32, 4), R::Integer=7)
    @assert 1 <= R <= 10
    r = ARS4x{Int(R)}(0, 0, 0, 0, 0, 0, 0)
    srand(r, seed)
end

function srand(r::ARS4x, seed::NTuple{4, Integer}=gen_seed(UInt32, 4))
    r.key = unsafe_load(Ptr{UInt128}(pointer_from_objref(seed)), 1)
    r.ctr1 = 0
    p = 0
    random123_r(r)
    r
end

@inline function random123_r{R}(r::ARS4x{R})
    ars1xm128i(r, Val{R}, r.ctr1, r.key)
    (r.x1, r.x2, r.x3, r.x4)
end
