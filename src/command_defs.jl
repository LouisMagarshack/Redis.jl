const EXEC = ["exec"]

baremodule Aggregate
    const NotSet = ""
    const Sum = "sum"
    const Min = "min"
    const Max = "max"
end

# Key commands
@redisfunction "del" Integer key...
@redisfunction "dump" AbstractString key
@redisfunction "exists" Bool key
@redisfunction "expire" Bool key seconds
@redisfunction "expireat" Bool key timestamp

# CAUTION:  this command will block until all keys have been returned
@redisfunction "keys" Set{AbstractString} pattern

@redisfunction "migrate" Bool host port key destinationdb timeout
@redisfunction "move" Bool key db
@redisfunction "persist" Bool key
@redisfunction "pexpire" Bool key milliseconds
@redisfunction "pexpireat" Bool key millisecondstimestamp
@redisfunction "pttl" Integer key
@redisfunction "randomkey" Nullable{AbstractString}
@redisfunction "rename" AbstractString key newkey
@redisfunction "renamenx" Bool key newkey
@redisfunction "restore" Bool key ttl serializedvalue
@redisfunction "scan" Tuple{AbstractString, Set{AbstractString}} cursor::Integer options...
@redisfunction "sort" Array{AbstractString, 1} key options...
@redisfunction "ttl" Integer key
function Base.keytype(conn::RedisConnection, key)
    response = do_command(conn, flatten_command("type", key))
    #convert_response(AbstractString, response)
end
function Base.keytype(conn::TransactionConnection, key)
    do_command(conn, flatten_command("type", key))
end

# String commands
@redisfunction "append" Integer key value
@redisfunction "bitcount" Integer key options...
@redisfunction "bitop" Integer operation destkey key keys...
@redisfunction "bitpos" Integer key bit options...
@redisfunction "decr" Integer key
@redisfunction "decrby" Integer key decrement
@redisfunction "get" Nullable{AbstractString} key
@redisfunction "getbit" Integer key offset
@redisfunction "getrange" AbstractString key start finish
@redisfunction "getset" AbstractString key value
@redisfunction "incr" Integer key
@redisfunction "incrby" Integer key increment::Integer

# Bulk string reply: the value of key after the increment,
# as per http://redis.io/commands/incrbyfloat
@redisfunction "incrbyfloat" AbstractString key increment::Float64
@redisfunction "mget" Array{Nullable{AbstractString}, 1} key keys...
@redisfunction "mset" Bool keyvalues
@redisfunction "msetnx" Bool keyvalues
@redisfunction "psetex" AbstractString key milliseconds value
@redisfunction "set" Bool key value options...
@redisfunction "setbit" Integer key offset value
@redisfunction "setex" AbstractString key seconds value
@redisfunction "setnx" Bool key value
@redisfunction "setrange" Integer key offset value
@redisfunction "strlen" Integer key

# Hash commands
@redisfunction "hdel" Integer key field fields...
@redisfunction "hexists" Bool key field
@redisfunction "hget" Nullable{AbstractString} key field
@redisfunction "hgetall" Dict{AbstractString, AbstractString} key
@redisfunction "hincrby" Integer key field increment::Integer

# Bulk string reply: the value of key after the increment,
# as per http://redis.io/commands/hincrbyfloat
@redisfunction "hincrbyfloat" AbstractString key field increment::Float64

@redisfunction "hkeys" Array{AbstractString, 1} key
@redisfunction "hlen" Integer key
@redisfunction "hmget" Array{Nullable{AbstractString}, 1} key field fields...
@redisfunction "hmset" Bool key value
@redisfunction "hset" Bool key field value
@redisfunction "hsetnx" Bool key field value
@redisfunction "hvals" Array{AbstractString, 1} key
@redisfunction "hscan" Tuple{AbstractString, Dict{AbstractString, AbstractString}} key cursor::Integer options...

# List commands
@redisfunction "blpop" Array{AbstractString, 1} keys timeout
@redisfunction "brpop" Array{AbstractString, 1} keys timeout
@redisfunction "brpoplpush" AbstractString source destination timeout
@redisfunction "lindex" Nullable{AbstractString} key index
@redisfunction "linsert" Integer key place pivot value
@redisfunction "llen" Integer key
@redisfunction "lpop" Nullable{AbstractString} key
@redisfunction "lpush" Integer key value values...
@redisfunction "lpushx" Integer key value
@redisfunction "lrange" Array{AbstractString, 1} key start finish
@redisfunction "lrem" Integer key count value
@redisfunction "lset" AbstractString key index value
@redisfunction "ltrim" AbstractString key start finish
@redisfunction "rpop" Nullable{AbstractString} key
@redisfunction "rpoplpush" Nullable{AbstractString} source destination
@redisfunction "rpush" Integer key value values...
@redisfunction "rpushx" Integer key value

# Set commands
@redisfunction "sadd" Integer key member members...
@redisfunction "scard" Integer key
@redisfunction "sdiff" Set{AbstractString} key keys...
@redisfunction "sdiffstore" Integer destination key keys...
@redisfunction "sinter" Set{AbstractString} key keys...
@redisfunction "sinterstore" Integer destination key keys...
@redisfunction "sismember" Bool key member

# CAUTION:  this command will block until all keys have been returned
@redisfunction "smembers" Set{AbstractString} key
@redisfunction "smove" Bool source destination member
@redisfunction "spop" Nullable{AbstractString} key
@redisfunction "srandmember" Nullable{AbstractString} key
@redisfunction "srandmember" Set{AbstractString} key count
@redisfunction "srem" Integer key member members...
@redisfunction "sunion" Set{AbstractString} key keys...
@redisfunction "sunionstore" Integer destination key keys...
@redisfunction "sscan" Tuple{AbstractString, Set{AbstractString}} key cursor::Integer options...

# Sorted set commands
#=
merl-dev: a number of methods were added to take AbstractString for score value
to enable score ranges like '(1 2,' or "-inf", "+inf",
as per docs http://redis.io/commands/zrangebyscore
=#

@redisfunction "zadd" Integer key score::Number member::AbstractString

# NOTE:  using ZADD with Dicts could introduce bugs if some scores are identical
@redisfunction "zadd" Integer key scorememberdict

#=
This following version of ZADD enables adding new members using `Tuple{Int64, AbstractString}` or
`Tuple{Float64, AbstractString}` for single or multiple additions to the sorted set without
resorting to the use of `Dict`, which cannot be used in the case where all entries have the same score.
=#
@redisfunction "zadd" Integer key scoremembertup scorememberstup...

@redisfunction "zcard" Integer key
@redisfunction "zcount" Integer key min max

# Bulk string reply: the new score of member (a double precision floating point number),
# represented as string, as per http://redis.io/commands/zincrby
@redisfunction "zincrby" AbstractString key increment member

@redisfunction "zlexcount" Integer key min max
@redisfunction "zrange" OrderedSet{AbstractString} key start finish options...
@redisfunction "zrangebylex" OrderedSet{AbstractString} key min max options...
@redisfunction "zrangebyscore" OrderedSet{AbstractString} key min max options...
@redisfunction "zrank" Nullable{Integer} key member
@redisfunction "zrem" Integer key member members...
@redisfunction "zremrangebylex" Integer key min max
@redisfunction "zremrangebyrank" Integer key start finish
@redisfunction "zremrangebyscore" Integer key start finish
@redisfunction "zrevrange" OrderedSet{AbstractString} key start finish options...
@redisfunction "zrevrangebyscore" OrderedSet{AbstractString} key start finish options...
@redisfunction "zrevrank" Nullable{Integer} key member
# ZCORE returns a Bulk string reply: the score of member (a double precision floating point
# number), represented as string.
@redisfunction "zscore" Nullable{AbstractString} key member
@redisfunction "zscan" Tuple{AbstractString, OrderedSet{AbstractString}} key cursor::Integer options...

function _build_store_internal(destination, numkeys, keys, weights, aggregate, command)
    length(keys) > 0 || throw(ClientException("Must supply at least one key"))
    suffix = AbstractString[]
    if length(weights) > 0
        suffix = map(string, weights)
        unshift!(suffix, "weights")
    end
    if aggregate != Aggregate.NotSet
        push!(suffix, "aggregate")
        push!(suffix, aggregate)
    end
    vcat([command, destination, string(numkeys)], keys, suffix)
end

# TODO: PipelineConnection and TransactionConnection
function zinterstore(conn::RedisConnectionBase, destination, numkeys,
    keys::Array, weights=[]; aggregate=Aggregate.NotSet)
    command = _build_store_internal(destination, numkeys, keys, weights, aggregate, "zinterstore")
    do_command(conn, command)
end

function zunionstore(conn::RedisConnectionBase, destination, numkeys::Integer,
    keys::Array, weights=[]; aggregate=Aggregate.NotSet)
    command = _build_store_internal(destination, numkeys, keys, weights, aggregate, "zunionstore")
    do_command(conn, command)
end

# HyperLogLog commands
@redisfunction "pfadd" Bool key element elements...
@redisfunction "pfcount" Integer key keys...
@redisfunction "pfmerge" Bool destkey sourcekey sourcekeys...

# Connection commands
@redisfunction "auth" AbstractString password
@redisfunction "echo" AbstractString message
@redisfunction "ping" AbstractString
@redisfunction "quit" Bool
@redisfunction "select" AbstractString index

# Transaction commands
@redisfunction "discard" Bool
@redisfunction "exec" Array{Bool} # only one element ever in this array?
@redisfunction "multi" Bool
@redisfunction "unwatch" Bool
@redisfunction "watch" Bool key keys...

# Scripting commands
# TODO: PipelineConnection and TransactionConnection
function evalscript{T<:AbstractString}(conn::RedisConnection, script::T, numkeys::Integer, args::Array{T, 1})
    fc = flatten_command("eval", script, numkeys, args)
    response = do_command(conn, flatten_command("eval", script, numkeys, args))
    convert_eval_response(Any, response)
end
evalscript{T<:AbstractString}(conn::RedisConnection, script::T) = evalscript(conn, script, 0, AbstractString[])

#################################################################
# TODO: NEED TO TEST BEYOND THIS POINT
@redisfunction "evalsha" Any sha1 numkeys keys args
@redisfunction "script_exists" Array script scripts...
@redisfunction "script_flush" AbstractString
@redisfunction "script_kill" AbstractString
@redisfunction "script_load" AbstractString script

# Server commands
@redisfunction "bgrewriteaof" Bool
@redisfunction "bgsave" AbstractString
@redisfunction "client_getname" AbstractString
@redisfunction "client_list" AbstractString
@redisfunction "client_pause" Bool timeout
@redisfunction "client_setname" Bool name
@redisfunction "cluster_slots" Array
@redisfunction "command" Array
@redisfunction "command_count" Integer
@redisfunction "command_info" Array command commands...
@redisfunction "config_get" Array parameter
@redisfunction "config_resetstat" Bool
@redisfunction "config_rewrite" Bool
@redisfunction "config_set" Bool parameter value
@redisfunction "dbsize" Integer
@redisfunction "debug_object" AbstractString key
@redisfunction "debug_segfault" Any
@redisfunction "flushall" AbstractString
@redisfunction "flushdb" AbstractString db
@redisfunction "info" AbstractString
@redisfunction "info" AbstractString section
@redisfunction "lastsave" Integer
@redisfunction "role" Array
@redisfunction "save" Bool
@redisfunction "slaveof" AbstractString host port
@redisfunction "_time" Array{AbstractString, 1}

function shutdown(conn::RedisConnectionBase; save=true)
    if !isConnected(conn)
        conn = restart(conn)
    end
    reply = ccall((:redisvCommand, "libhiredis"), Ptr{RedisReply}, (Ptr{RedisContext}, Ptr{UInt8}), conn.context,
        "shutdown " * ifelse(save, "save", "nosave"))
end

#= Redis Modules - until Redis 4.0 (fall 2016) requires compiling Redis from unstable branch
- wget https://github.com/antirez/redis/archive/unstable.tar.gz
- tar xvzf unstable.tar.gz
- cd redis-unstable && make && sudo make install

and for the following online stats methods
- wget https://github.com/merl-dev/RediStats/archive/master.tar.gz
- tar xvzf master.tar.gz
- cd RediStats-master && make

see
- https://github.com/RedisLabs/RedisModulesSDK
- https://github.com/merl-dev/RediStats for installation and documentation
=#
function module_list(conn)
    do_command(conn, "module list")
end
function module_load(conn, modules...)
    do_command(conn, "module load $(modules...)")
end
export module_list, module_load

# online moments
@redisfunction "osnew" AbstractString key::AbstractString
@redisfunction "oscount" Integer key::AbstractString
@redisfunction "ospush" Integer key::AbstractString newvalues...
@redisfunction "osmean" Float64 key::AbstractString
@redisfunction "osvar" Float64 key::AbstractString
@redisfunction "osstd" Float64 key::AbstractString
@redisfunction "osskew" Float64 key::AbstractString
@redisfunction "oskurt" Float64 key::AbstractString
@redisfunction "osmerge" AbstractString dest::AbstractString src...
export osnew, oscount, ospush, osmean, osstd, osvar, osskew, oskurt, osmerge

# online linreg
@redisfunction "linregnew" AbstractString key::AbstractString
@redisfunction "linregcount" Integer key::AbstractString
@redisfunction "linregpush" Integer key::AbstractString values...
@redisfunction "linregslope" Float64 key::AbstractString
@redisfunction "linregintercept" Float64 key::AbstractString
@redisfunction "linregcov" Float64 key::AbstractString
@redisfunction "linregcorr" Float64 key::AbstractString
@redisfunction "linregmse" Float64 key::AbstractString
@redisfunction "linregpredict" Float64 key::AbstractString xvalue
@redisfunction "linregmerge" AbstractString dest::AbstractString src...
export linregnew, linregcount, linregpush, linregslope, linregintercept, linregcov, linregcorr, linregmse, linregpredict, linregmerge

# online extrema
@redisfunction "exnew" AbstractString key::AbstractString
@redisfunction "excount" Integer key::AbstractString
@redisfunction "expush" Integer key::AbstractString newvalue...
@redisfunction "exmin" Float64 key::AbstractString
@redisfunction "exmax" Float64 key::AbstractString
@redisfunction "exmerge" AbstractString dest::AbstractString src...
@redisfunction "exinit" AbstractString key::AbstractString n::Integer initmin initmax
export exnew, excount, expush, exmin, exmax, exmerge, exinit

# rngs
@redisfunction "rngnew" AbstractString key::AbstractString seed...
@redisfunction "rngnew" AbstractString key::AbstractString seed::Integer maxint::Integer
@redisfunction "rngreseed" AbstractString key::AbstractString seed::Integer
@redisfunction "rnglistgsltypes" Array{AbstractString, 1}
@redisfunction "rngget" Float64 key::AbstractString
@redisfunction "rnggetint" Integer key::AbstractString
@redisfunction "rnggauss" AbstractString key::AbstractString seed...
@redisfunction "rnggauss" AbstractString key::AbstractString seed::Integer mean::Float64 std::Float64
@redisfunction "rnggaussget" Float64 key::AbstractString
@redisfunction "rnggaussprob" Float64 key::AbstractString x::Float64
@redisfunction "rnggaussarr" AbstractString key::AbstractString seed::Integer mean::Float64 std::Float64 N::Integer
@redisfunction "rngpoisson" AbstractString key::AbstractString seed::Integer mean::Float64
@redisfunction "rngpoissonget" Integer key::AbstractString
@redisfunction "rngpoissonprob" Float64 key::AbstractString x::Integer
@redisfunction "rngpoissonarr" AbstractString key::AbstractString seed::Integer mean::Float64 N::Integer
@redisfunction "rngbinomial" AbstractString key::AbstractString seed::Integer n::Integer p::Float64
@redisfunction "rngbinomialget" Integer key::AbstractString
@redisfunction "rngbinomialprob" Float64 key::AbstractString x::Integer
@redisfunction "rngbinomialarr" AbstractString key::AbstractString seed::Integer n::Integer p::Float64 N::Integer
@redisfunction "rngexp" AbstractString key::AbstractString seed::Integer mean::Float64
@redisfunction "rngexpget" Float64 key::AbstractString
@redisfunction "rngexpprob" Float64 key::AbstractString x::Float64
@redisfunction "rngexparr" Float64 key::AbstractString seed::Integer mean::Float64 N::Integer
@redisfunction "rngarrdesc" AbstractString key::AbstractString
@redisfunction "rngarrayrange" Array{AbstractString, 1} key::AbstractString start::Integer stop::Integer
export rngnew, rngreseed, rnglistgsltypes,
       rngget, rnggetint, 
       rnggauss, rnggaussget, rnggaussprob, rnggaussarr,
       rngpoisson, rngpoissonget, rngpoissonprob, rngpoissonarr,
       rngbinomial, rngbinomialget, rngbinomialprob, rngbinomialarr,
       rngexp, rngexpget, rngexpprob, rngexparr,
       rngarrdesc, rngarrayrange
         

# Sentinel commands
@sentinelfunction "master" Dict{AbstractString, AbstractString} mastername
@sentinelfunction "reset" Integer pattern
@sentinelfunction "failover" Any mastername
@sentinelfunction "monitor" Bool name ip port quorum
@sentinelfunction "remove" Bool name
@sentinelfunction "set" Bool name option value

# Custom commands (PubSub/Transaction)
@redisfunction "publish" Integer channel message

#Need a specialized version of execute to keep the connection in the transaction state
function exec(conn::TransactionConnection)
    response = do_command(conn, EXEC)
    multi(conn)
    response
end

###############################################################
# The following Redis commands can be typecast to Julia structs
###############################################################

function time(c::RedisConnection)
    t = _time(c)
    s = parse(Int,t[1])
    ms = parse(Float64, t[2])
    s += (ms / 1e6)
    return unix2datetime(s)
end
