module RandAcceptReject

import Base: rand

export ARDist, rand

struct ARDist
  low::Float64
  high::Float64
  f::Function
end

function rand(d::ARDist)
  xs = range(d.low, d.high, 100)
  ys = d.f.(xs)
  x = d.low + Base.rand() * (d.high - d.low)
  u = Base.rand() * maximum(ys)
  if u < d.f(x)
    return x
  else
    return nothing
  end
end

function rand(d::ARDist, len::Int)
  xs = range(d.low, d.high, 100)
  ys = d.f.(xs)
  rs = Float64[]
  while length(rs) < len
    x = d.low + Base.rand() * (d.high - d.low)
    u = Base.rand() * maximum(ys)
    if u < d.f(x)
      push!(rs, x)
    end
  end
  rs
end

greet() = print("Hello World!")

end # module RandAcceptReject
