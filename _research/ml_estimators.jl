using DrWatson
@quickactivate
using LsqFit, WaveDump, CairoMakie, FHist, Statistics, Distributions

function gaus(x, p)
  a, μ, σ = p
  @. a * exp(-(x - μ)^2 / 2σ^2)
end

trued = Exponential(1.0)

h = Hist1D(Float64, bins=0.5:0.01:1.5)
for _ in 1:50000
  vals = rand(trued, 50)
  τs = range(0.2, 1.5, 1000)
  ds = Exponential.(τs)
  res = [sum(logpdf.(d, vals)) for d in ds]
  i = argmax(res)
  push!(h, τs[i])
end
lows = [50, 0.5, 0.001]
highs = [50000, 1.5, 2.0]
gaus_fit = curve_fit(gaus, bincenters(h), bincounts(h), [500, 1.0, 1.0], lower=lows, upper=highs)
fig, ax, h1 = hist(h)
lines!(bincenters(h), gaus(bincenters(h), coef(gaus_fit)), color=:red)
@show coef(gaus_fit)
display(fig)