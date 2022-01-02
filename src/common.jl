
# The file contains definitions of some commonly used functions


"""
    Constructs the reduced Groebner basis given that G is itself a Groebner basis,
    strightforward approach for now :D
    Note: groebner bases generating the same ideal meet the same reduced form

    Guaranteed that If <f1..fn> equals <g1..gm> as ideals, then
        reducegb(groebner(<f1..fn>)) = reducegb(groebner(<g1..gm>))

    Normalizes generators and sorts them by leading monomial, which is controversial
"""
function reducegb(G)
    reducegb!(deepcopy(G))
end

function reducegb!(G)
    for i in 1:length(G)
        G[i] = normal_form(G[i], G[1:end .!= i])
    end
    filter!(!iszero, G)
    scale = f -> map_coefficients(c -> c // leading_coefficient(f), f)
    # TODO: questionable over QQ
    map!(scale, G, G)
    sort!(G, by=leading_monomial)
end


#------------------------------------------------------------------------------

# Normal form of `h` with respect to generators `G`
#
# The function is taken from Christian Eder course
# https://www.mathematik.uni-kl.de/~ederc/teaching/2019/computeralgebra.html#news
function normal_form_eder(h, G)
    i = 0
    while true
        if iszero(h)
            return h
        end
        i = 1
        while i <= length(G)
            mul = div(leading_monomial(h), leading_monomial(G[i]))
            if !iszero(mul)
                h -= leading_coefficient(h) * 1//leading_coefficient(G[i]) * mul * G[i]
                i = 1
                break
            end
            i = i + 1
        end
        if i > length(G)
            return h
        end
    end
end

# Normal form of `h` with respect to generators `G`
"""
    Returns the normal form of polynomial h w.r.t Groebner basis G

"""
function normal_form(h, G)
    flag = false
    while true
        # PROFILER: we can do better instead of terms
        #           Probably change iteration order
        hprev = deepcopy(h)
        for t in terms(h)
            for g in G
                # does, mul = term_divides_3(t, g)
                is_divisible, _ = divides(t, leading_monomial(g))
                if is_divisible
                    mul = AbstractAlgebra.divexact(t, leading_term(g))
                    # PROFILER: slow
                    h -= mul * g
                    flag = true
                    break
                end
            end
            flag && break
        end
        !flag && break
        flag = false
        # LOL
        hprev == h && break
    end
    h
end

#------------------------------------------------------------------------------

function muls(f, g)
    lmi = leading_monomial(f)
    lmj = leading_monomial(g)
    lcm = AbstractAlgebra.lcm(lmi, lmj)
    mji = div(lcm, lmi)
    mij = div(lcm, lmj)
    return mji, mij
end

# generation of spolynomial of f and g
#
# The function is taken from Christian Eder course
# https://www.mathematik.uni-kl.de/~ederc/teaching/2019/computeralgebra.html#news
function spoly(f, g)
    mji, mij  = muls(f, g)
    h = 1//leading_coefficient(f) * mji * f - 1//leading_coefficient(g) * mij * g
    return h
end

#------------------------------------------------------------------------------


"""
    Checks if the given set of polynomials `fs` is a Groebner basis,
         i.e all spoly's are reduced to zero.

    If `initial_gens` parameter is provided, also assess `initial_gens ⊆ fs` as ideals
"""
function isgroebner(fs; initial_gens=[])
    for f in fs
        for g in fs
            if !iszero( normal_form(spoly(f, g), fs) )
                return false
            end
        end
    end
    if !isempty(initial_gens)
        return all(
            i -> normal_form( i, fs ) == 0,
            initial_gens
        )
    end
    return true
end

#------------------------------------------------------------------------------

change_ordering(f, ordering) = change_ordering([f], ordering)

# changes the ordering of set of polynomials into `ordering`
function change_ordering(fs::AbstractArray, ordering)
    R = parent(first(fs))
    Rord, _ = PolynomialRing(base_ring(R), string.(gens(R)), ordering=ordering)
    map(f -> change_base_ring(base_ring(R), f, parent=Rord), fs)
end
