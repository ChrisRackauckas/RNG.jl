const TEST_NAME = "PCG_RSH_RS"

include("common.jl")

using RNG.PCG

r = PCGStateSetseq(UInt64, PCG_XSH_RS, 123 % UInt64, 456 % UInt64)

test_all(r, 100_000_000)
