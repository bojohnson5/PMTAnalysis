using DrWatson
@quickactivate
using LsqFit, WaveDump, CairoMakie, FHist, Statistics, Distributions

function spectrum(w, range)
  _, m = size(w.waveforms)
  avgw = sum(w.waveforms, dims=2) ./ m |> vec
  bl = mean(avgw[1:100])
  min_i = argmin(avgw)
  spec = Hist1D(Float64, bins=-20:5:100)
  for i in 1:m
    wf = w.waveforms[:, i] .- bl
    if minimum(wf[1:100]) < -10.0
      println("skipping due to baseline issues")
    end
    push!(spec, sum(wf[min_i-range[1]:min_i+range[2]]) * -1.0)
  end
  display(hist(spec, axis=(; yscale=log10)))
  spec
end

w = WaveDumpFile(DT5720, "/N/project/ceem_coherent/CENNS750/PMTtests/data/summer_2023/wave1001.dat")
# ranges = ([10, 10], [5, 5], [5, 10], [12, 18])
# spectrum.(Ref(w), ranges)
s = spectrum(w, [5, 5])
d = Normal(0, 5.5)
σs = range(0.1, 5.5, length=100)
ds = Normal.(0, σs)
res = [sum(logpdf.(d, bincounts(s))) for d in ds]
# sum(logpdf.(d, bincounts(s)))