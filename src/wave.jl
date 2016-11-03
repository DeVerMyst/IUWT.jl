function iuwt_decomp(x::Array{Float64,2}, scale::Int64; store_c0=false)

    filter = (1/16)*[1,4,6,4,1]

    coeff = zeros(Float64,size(x,1),size(x,2),scale)
    c0 = copy(x)

    for i in 1:scale
        c = for_a_trous(c0,filter,i)
        c1 = for_a_trous(c,filter,i)
        coeff[:,:,i] = c0 - c1
        c0 = copy(c)
    end
    if store_c0 == true
        return coeff,c0
    else
        return coeff
    end
end

function iuwt_recomp(x::Array{Float64,3}, scale::Int64; c0=false)

    filter = (1/16)*[1,4,6,4,1]

    max_scale = size(x,3) + scale

    if c0 != false
        recomp = c0
    else
        recomp = zeros(Float64,size(x,1),size(x,2))
    end

    for i in range(max_scale,-1,size(x,3))
        recomp = for_a_trous(recomp,filter,i) + x[:,:,i-scale]
    end
    if scale > 0
        for i in range(scale,-1,scale)
            recomp = for_a_trous(recomp,filter,i)
        end
    end

    return recomp
end

function a_trous(c0::Array{Float64,2}, filter::Array{Float64,1}, scale::Int64)

    scale = scale - 1
    tmp = filter[3]*c0

    tmp[(2^(scale+1))+1:end,:] += filter[1]*c0[1:(end-(2^(scale+1))),:]
    tmp[1:(2^(scale+1)),:] += filter[1]*c0[2^(scale+1):-1:1,:]

    tmp[(2^(scale))+1:end,:] += filter[2]*c0[1:(end-(2^(scale))),:]
    tmp[1:(2^(scale)),:] += filter[2]*c0[2^(scale):-1:1,:]

    tmp[1:(end-(2^(scale))),:] += filter[4]*c0[(2^(scale))+1:end,:]
    tmp[(end-(2^(scale)))+1:end,:] += filter[4]*c0[end:-1:end-2^(scale)+1,:]

    tmp[1:(end-(2^(scale+1))),:] += filter[5]*c0[2^(scale+1)+1:end,:]
    tmp[(end-(2^(scale+1))+1):end,:] += filter[5]*c0[end:-1:end-2^(scale+1)+1,:]

    c1 = filter[3]*tmp

    c1[:,(2^(scale+1))+1:end] += filter[1]*tmp[:,1:(end-(2^(scale+1)))]
    c1[:,1:(2^(scale+1))] += filter[1]*tmp[:,2^(scale+1):-1:1]

    c1[:,(2^(scale))+1:end] += filter[2]*tmp[:,1:(end-(2^(scale)))]
    c1[:,1:(2^(scale))] += filter[2]*tmp[:,2^(scale):-1:1]

    c1[:,1:(end-(2^(scale)))] += filter[4]*tmp[:,(2^(scale))+1:end]
    c1[:,(end-(2^(scale))+1):end] += filter[4]*tmp[:,end:-1:end-2^(scale)+1]

    c1[:,1:(end-(2^(scale+1)))] += filter[5]*tmp[:,(2^(scale+1))+1:end]
    c1[:,(end-(2^(scale+1))+1):end] += filter[5]*tmp[:,end:-1:end-2^(scale+1)+1]

    return c1

end

function for_a_trous(c0::Array{Float64,2}, filter::Array{Float64,1}, scale::Int64)

  N = size(c0,1)
  scale = scale - 1

  ind0 = 2^(scale)
  ind1 = 2^(scale+1)

  tmp = filter[3]*c0


  for ind1N in ind1+1:N
      tmp[ind1N,:] += filter[1]*c0[ind1N - ind1,:]
  end
  for iind1 in 1:ind1
      tmp[iind1,:] += filter[1]*c0[ind1+1 - iind1,:]
  end
  for ind0N in ind0+1:N
      tmp[ind0N,:] += filter[2]*c0[ind0N - ind0,:]
  end
  for iind0 in 1:ind0
      tmp[iind0,:] += filter[2]*c0[ind0+1 - iind0,:]
  end
  for ind0N in ind0+1:N
      tmp[ind0N - ind0,:] += filter[4]*c0[ind0N,:]
  end
  for ind in 1:ind0
      tmp[N-ind0 + ind,:] += filter[4]*c0[N+1 - ind,:]
  end
  for ind1N in ind1+1:N
      tmp[ind1N - ind1,:] += filter[5]*c0[ind1N,:]
  end
  for ind in 1:ind1
      tmp[N-ind1+ind,:] += filter[5]*c0[N+1-ind,:]
  end
  c1 = filter[3]*tmp

  for ind1N in ind1+1:N
      c1[:,ind1N] += filter[1]*tmp[:,ind1N - ind1]
  end
  for iind1 in 1:ind1
      c1[:,iind1] += filter[1]*tmp[:,ind1+1 - iind1]
  end
  for ind0N in ind0+1:N
      c1[:,ind0N] += filter[2]*tmp[:,ind0N - ind0]
  end
  for iind0 in 1:ind0
      c1[:,iind0] += filter[2]*tmp[:,ind0+1 - iind0]
  end
  for ind0N in ind0+1:N
      c1[:,ind0N - ind0] += filter[4]*tmp[:,ind0N]
  end
  for ind in 1:ind0
      c1[:,N-ind0+ind] += filter[4]*tmp[:,N+1-ind]
  end
  for ind1N in ind1+1:N
      c1[:,ind1N - ind1] += filter[5]*tmp[:,ind1N - ind1]
  end
  for ind in 1:ind1
      c1[:,N-ind1+ind] += filter[5]*tmp[:,N+1-ind]
  end

    return c1

end

function iuwt_decomp_adj(u,scale)
    htu = iuwt_decomp(u[:,:,1],1)[:,:,1]
        for k in 2:scale
            htu += iuwt_decomp(u[:,:,k],k)[:,:,k]
        end
    return htu
end
