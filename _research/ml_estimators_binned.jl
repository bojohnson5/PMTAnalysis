using DrWatson
@quickactivate
using CairoMakie, FHist, BlackBoxOptim, RandAcceptReject, Distributions, WaveDump, LsqFit

function gaus(x, p)
  a, μ, σ = p
  a * exp(-(x - μ)^2 / 2σ^2)
end

function spectrum(w, r)
  _, m = size(w.waveforms)
  avgw = sum(w.waveforms, dims=2) ./ m |> vec
  bl = mean(avgw[1:100])
  min_i = argmin(avgw)
  spec = Hist1D(Float64, bins=range(-22, 103, length=47))
  for i in 1:m
    wf = w.waveforms[:, i] .- bl
    if minimum(wf[1:100]) < -10.0
      println("skipping due to baseline issues")
    end
    push!(spec, sum(wf[min_i-r[1]:min_i+r[2]]) * -1.0)
  end
  spec
end

w = WaveDumpFile(DT5720, "/N/project/ceem_coherent/CENNS750/PMTtests/data/summer_2023/wave1001.dat")
s = spectrum(w, [5, 5])

# true_p = [1.0, 3.0, 3.0]
# myf(x) = gaus(x, true_p)
# vals = rand(ARDist(-1, 7, myf), 50000)
# s = Hist1D(vals, range(-1, 7, 100))
ntot = integral(s)
nbins = length(bincenters(s))

loglike(θ) = begin
  # myfunction(x) = gaus(x, [maximum(bincounts(s)), θ[1], θ[2]])
  myfunction(x) = gaus(x, [1e4, θ[1], θ[2]]) + gaus(x, [1e2, θ[3], θ[4]])
  md = ARDist(first(binedges(s)), last(binedges(s)), myfunction)
  pdf = normalize(Hist1D(rand(md, 1000), binedges(s)))
  νs = bincounts(pdf * ntot)
  -sum(bincounts(s) .* log.(νs) |> filter(isfinite))
end

res = bboptimize(loglike; SearchRange=[(-2, 2), (1, 10), (40, 60), (5, 20)], Method=:adaptive_de_rand_1_bin_radiuslimited)
a = best_candidate(res)

xs = range(first(binedges(s)), last(binedges(s)), 1000)
ys = gaus.(xs, Ref([lookup(s, a[1]), a[1:2]...])) .+ gaus.(xs, Ref([lookup(s, a[3]), a[3:4]...]))
fig, ax, h1 = hist(s, axis=(; yscale=log10))
lines!(xs, ys, color=:red)

true_vals = gaus.(bincenters(s), Ref([lookup(s, a[1]), a[1:2]...])) .+ gaus.(bincenters(s), Ref([lookup(s, a[3]), a[3:4]...]))
Χ² = sum((bincounts(s) .- true_vals) .^2 ./ true_vals)
@show Χ² / (length(true_vals) - length(a))

myfunction(x, p) = gaus.(x, Ref(p[1:3])) .+ gaus.(x, Ref(p[4:6]))
p0 =   [1e4,  0,    4, 1e2, 45, 15]
lows = [1e3, -2,  0.5,  50, 40, 10]
high = [5e4,  2,   10, 500, 50, 20]
res = curve_fit(myfunction, bincenters(s), bincounts(s), p0, lower=lows, upper=high)
@show coef(res)
lines!(xs, myfunction(xs, coef(res)), color=:green)

true_vals = myfunction(bincenters(s), coef(res))
Χ² = sum((bincounts(s) .- true_vals) .^2 ./ true_vals)
@show Χ² / (length(true_vals) - length(coef(res)))

display(fig)