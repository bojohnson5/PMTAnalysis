module WaveDump

export DT5720
export WaveDumpFile

abstract type CaenDigitizer end

struct DT5720 <: CaenDigitizer end

struct WaveDumpFile
  headers::Matrix{Int32}
  waveforms::Matrix{Int16}
end

function WaveDumpFile(::Type{DT5720}, f::AbstractString)
  header_length = 6
  header_size = 4
  sample_size = 2
  h = Int32[]
  wfs = Int16[]
  open(f, "r") do io
    event_size, _, _, _, _, _ = read!(io, Vector{Int32}(undef, header_length))
    wf_length = (event_size - header_length * header_size) ÷ sample_size
    seekstart(io)
    while !eof(io)
      append!(h, read!(io, Vector{Int32}(undef, header_length)))
      append!(wfs, read!(io, Vector{Int16}(undef, wf_length)))
    end
    hs = reshape(h, header_length, :)
    ws = reshape(wfs, wf_length, :)
    WaveDumpFile(hs, ws)
  end
end

end # module WaveDump
