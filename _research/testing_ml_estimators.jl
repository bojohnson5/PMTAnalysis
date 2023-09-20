using DrWatson
@quickactivate
using CairoMakie, FHist, Statistics,  BlackBoxOptim, RandAcceptReject, WaveDump, Distributions

function gaus(x, p)
  a, μ, σ = p
  a * exp(-(x - μ)^2 / 2σ^2)
end

true_p = [10.0, 1.0, 1.0]
myf(x) = gaus(x, true_p)
vals = rand(ARDist(-2, 4, myf), 50000)
s = Hist1D(vals, range(-1, 3, 100))

ntot = integral(s)
nbins = length(bincenters(s))

loglike(θ) = begin
  myfunction(x) = gaus(x, [5.0, θ[2], θ[3]])
  md = ARDist(first(binedges(s)), last(binedges(s)), myfunction)
  pdf = normalize(Hist1D(rand(md, 1000), binedges(s)))
  νs = bincounts(pdf * ntot)
  -sum(bincounts(s) .* log.(νs) |> filter(isfinite))
end

myfunction(x) = gaus(x, [1.0, 1.1, 1.0])
md = ARDist(first(binedges(s)), last(binedges(s)), myfunction)
pdf = normalize(Hist1D(rand(md, 1000), binedges(s)))
νs = bincounts(pdf * ntot)
stairs(normalize(s))