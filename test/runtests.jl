using Redis
import DataStructures: OrderedSet

using Base.Test

include(Pkg.dir("Redis","test","client_tests.jl"))
include(Pkg.dir("Redis","test","redis_tests.jl"))
