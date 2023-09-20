using CairoMakie, JLD2, CodecZlib

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
  headers = Int32[]
  wfs = Int16[]
  open(f, "r") do io
    event_size, _, _, _, _, _ = read!(io, Vector{Int32}(undef, header_length))
    wf_length = (event_size - header_length * header_size) ÷ sample_size
    seekstart(io)
    while !eof(io)
      append!(headers, read!(io, Vector{Int32}(undef, header_length)))
      append!(wfs, read!(io, Vector{Int16}(undef, wf_length)))
    end
    hs = reshape(headers, header_length, :)
    ws = reshape(wfs, wf_length, :)
    WaveDumpFile(hs, ws)
  end
end

f = "/N/project/ceem_coherent/CENNS750/PMTtests/data/summer_2023/wave1174.dat"
fs = ["/N/project/ceem_coherent/CENNS750/PMTtests/data/summer_2023/wave100$i.dat" for i in 1:9]
wds = WaveDumpFile.(DT5720, fs)
wds[1].headers
jldsave("testing.jld2", true; wds=wds[1])
# avg_wf = sum(wvfs, dims=2) ./ i
# fig, ax, l = lines(avg_wf[:, 1] .* -1)
# xlims!(200, 300)
# display(fig)