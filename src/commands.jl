# Called by flatten_command. A `token` can be a String, Array, Set, Dict, or Tuple, depending on the command
flatten(token::Number) = string(token)
flatten(token::AbstractString) = token
flatten(token::Array) = map(string, token)
flatten(token::Set) = map(string, collect(token))
function flatten(token::Dict)
    r=AbstractString[]
    for (k,v) in token
        push!(r, string(k))
        push!(r, string(v))
    end
    r
end
function flatten{T<:Number, U<:AbstractString}(token::Tuple{T, U}...)
    r=AbstractString[]
    for item in token
        push!(r, string(item[1]))
        push!(r, item[2])
    end
    r
end

flatten_command(command...) = vcat(map(flatten, command)...)

if !haskey(ENV, "REDIS_CONVERT_REPLY") || ENV["REDIS_CONVERT_REPLY"] == "true"
    macro redisfunction(command::AbstractString, ret_type, args...)
        func_name = esc(Symbol(command))
        command = lstrip(command,'_')
        command = split(command, '_')


        if length(args) > 0
            return quote
                function $(func_name)(conn::RedisConnection, $(args...))
                    response = do_command(conn, flatten_command($(command...), $(args...)))
                    convert_response($ret_type, response)
                end
                function $(func_name)(conn::TransactionConnection, $(args...))
                    do_command(conn, flatten_command($(command...), $(args...)))
                end
                function $(func_name)(conn::PipelineConnection, $(args...))
                    do_command(conn, flatten_command($(command...), $(args...)))
                    conn.count += 1
                end
            end
        else
            return quote
                function $(func_name)(conn::RedisConnection)
                    response = do_command(conn, flatten_command($(command...)))
                    convert_response($ret_type, response)
                end
                function $(func_name)(conn::TransactionConnection)
                    do_command(conn, flatten_command($(command...)))
                end
                function $(func_name)(conn::PipelineConnection)
                    do_command(conn, flatten_command($(command...)))
                    conn.count += 1
                end
            end
        end
    end
else
    macro redisfunction(command::AbstractString, ret_type, args...)
        func_name = esc(Symbol(command))
        command = lstrip(command,'_')
        command = split(command, '_')


        if length(args) > 0
            return quote
                function $(func_name)(conn::RedisConnection, $(args...))
                    do_command(conn, flatten_command($(command...), $(args...)))
                end
                function $(func_name)(conn::TransactionConnection, $(args...))
                    do_command(conn, flatten_command($(command...), $(args...)))
                end
                function $(func_name)(conn::PipelineConnection, $(args...))
                    do_command(conn, flatten_command($(command...), $(args...)))
                    conn.count += 1
                end
            end
        else
            return quote
                function $(func_name)(conn::RedisConnection)
                    do_command(conn, flatten_command($(command...)))
                end
                function $(func_name)(conn::TransactionConnection)
                    do_command(conn, flatten_command($(command...)))
                end
                function $(func_name)(conn::PipelineConnection)
                    do_command(conn, flatten_command($(command...)))
                    conn.count += 1
                end
            end
        end
    end
end
"Issues a blocking command to hiredis."
function do_command(conn::RedisConnectionBase, command::AbstractString)
    if conn.context == 0 # !isdefined(:redisContext)
        conn = restart(conn)
    end
    reply = ccall((:redisvCommand, "libhiredis"), Ptr{RedisReply}, (Ptr{RedisContext}, Ptr{UInt8}), conn.context, command)
    get_result(reply)
end

"Issues a blocking command to hiredis, accepting command arguments as an Array."
function do_command{S<:Any}(conn::RedisConnectionBase, argv::Array{S,1})
    if conn.context == 0 # !isdefined(:redisContext)
        conn = restart(conn)
    end
    reply = ccall((:redisCommandArgv, "libhiredis"), Ptr{RedisReply}, (Ptr{RedisContext}, Int32, Ptr{Ptr{UInt8}}, Ptr{UInt}), conn.context, length(argv), argv, C_NULL)
    get_result(reply)
end

"""
redundant
"""
function do_command_no_reply{S<:Any}(conn::RedisConnectionBase, argv::Array{S,1})
    if conn.context == 0 # !isdefined(:redisContext)
        conn = restart(conn)
    end
    reply = ccall((:redisCommandArgv, "libhiredis"), Ptr{RedisReply}, (Ptr{RedisContext}, Int32, Ptr{Ptr{UInt8}}, Ptr{UInt}), conn.context, length(argv), argv, C_NULL)
    get_result(reply)
end

"Switches between blocking and pipelined command execution according to flag."
function docommand(conn::RedisConnectionBase, cmd::AbstractString, pipeline::Bool)
    (pipeline || (pipelinedCommandCount::Integer > 0)) ? pipeline_command(cmd) : do_command(conn, cmd)
end
