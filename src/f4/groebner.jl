
#------------------------------------------------------------------------------

function assure_ordering!(ring, exps, coeffs, metainfo)
    if ring.ord != metainfo.computeord
        sort_input_to_change_ordering(exps, coeffs, metainfo.computeord)
    end
    ring.ord = metainfo.computeord
end

# TODO: change project structure

function input_statistics(exps)
    sz = length(exps)
    deg = maximum(sum(e[1]) for e in exps)
    sz, deg
end

function select_tablesize(ring, exps)
    nvars = ring.nvars
    sz = length(exps)

    tablesize = 2^10
    if nvars > 4
        tablesize = 2^14
    end
    if nvars > 7
        tablesize = 2^16
    end

    if sz < 3
        tablesize = div(tablesize, 2)
    end
    if sz < 2
        tablesize = div(tablesize, 2)
    end

    tablesize
end

function cleanup_gens!(ring, gens_ff, prime)
    gens_ff.ch = prime
    ring.ch = prime
    normalize_basis!(gens_ff)
end

# Mutate everything!

#------------------------------------------------------------------------------
# Finite field groebner

function groebner_ff(
            ring::PolyRing,
            exps::Vector{Vector{Vector{UInt16}}},
            coeffs::Vector{Vector{UInt64}},
            reduced::Bool,
            rng::Rng,
            meta::GroebnerMetainfo) where {Rng<:Random.AbstractRNG}

    # select hashtable size
    tablesize = select_tablesize(ring, exps)

    basis, ht = initialize_structures(
                        ring, exps, coeffs, rng, tablesize)

    f4!(ring, basis, ht, reduced, meta.linalg)

    gbexps = hash_to_exponents(basis, ht)
    gbexps, basis.coeffs
end

#------------------------------------------------------------------------------
# Rational field groebner

function groebner_qq(
            ring::PolyRing,
            exps::Vector{Vector{ExponentVector}},
            coeffs::Vector{Vector{CoeffQQ}},
            reduced::Bool,
            rng::Rng,
            meta::GroebnerMetainfo) where {Rng<:Random.AbstractRNG}

    # we can mutate coeffs and exps here
    # TODO: and we should do it

    # select hashtable size
    tablesize = select_tablesize(ring, exps)
    @info "Selected tablesize $tablesize"

    # initialize hashtable and finite field generators structs
    gens_temp_ff, ht = initialize_structures_ff(ring, exps,
                                        coeffs, rng, tablesize)
    gens_ff = copy_basis_thorough(gens_temp_ff)

    # now hashtable is filled correctly,
    # and gens_temp_ff exponents are correct and in correct order.
    # gens_temp_ff coefficients are filled with random stuff and
    # gens_temp_ff.ch is 0

    # to store integer and rational coefficients of groebner basis
    coeffaccum  = CoeffAccum()
    # to store BigInt buffers and reduce overall memory usage
    coeffbuffer = CoeffBuffer()

    # scale coefficients of input to integers
    coeffs_zz = scale_denominators(coeffbuffer, coeffs)

    # keeps track of used prime numbers
    primetracker = PrimeTracker(coeffs_zz)

    #=
        coeffs and coeffs_zz should be *unchanged* during whole computation
    =#

    i = 1
    while true
        prime = nextluckyprime!(primetracker)
        @info "$i: selected lucky prime $prime"

        # perform reduction and store result in gens_ff
        reduce_modulo!(coeffbuffer, coeffs_zz, gens_ff.coeffs, prime)

        # do some things to ensure generators are correct
        cleanup_gens!(ring, gens_ff, prime)

        # compute groebner basis in finite field
        #=
        Need to make sure input invariants in f4! are satisfied, f4.jl for details
        =#
        f4!(ring, gens_ff, ht, reduced, meta.linalg)
        if meta.usefglm
            # fglm_f4!(ring, gens_ff, ht)
        end

        # reconstruct into integers
        @info "CRT modulo ($(primetracker.modulo), $(prime))"
        reconstruct_crt!(coeffbuffer, coeffaccum, primetracker, gens_ff.coeffs, prime)

        # reconstruct into rationals
        @info "Reconstructing modulo $(primetracker.modulo)"
        reconstruct_modulo!(coeffbuffer, coeffaccum, primetracker)

        if correctness_check!(coeffaccum, coeffbuffer, primetracker, meta,
                                ring, coeffs, coeffs_zz, gens_temp_ff, gens_ff, ht)
            @info "Success!"
            break
        end

        # copy basis so that we initial exponents dont get lost
        gens_ff = copy_basis_thorough(gens_temp_ff)

        i += 1
    end

    # normalize_coeffs!(gbcoeffs_qq)
    gb_exps = hash_to_exponents(gens_ff, ht)
    gb_exps, coeffaccum.gb_coeffs_qq
end

#######################################
# Finite field isgroebner

# UWU!
function isgroebner_ff(
            ring::PolyRing,
            exps::Vector{Vector{ExponentVector}},
            coeffs::Vector{Vector{CoeffFF}},
            rng,
            meta)

    isgroebner_f4(ring, exps, coeffs, rng)
end

#######################################
# Rational field groebner

# TODO
function isgroebner_qq(
            ring::PolyRing,
            exps::Vector{Vector{ExponentVector}},
            coeffs::Vector{Vector{CoeffQQ}},
            rng,
            meta)

    # if randomized result is ok
    if !meta.guaranteedcheck
        coeffs_zz = scale_denominators(coeffs)
        goodprime = nextgoodprime(coeffs_zz, Int[], 2^30 + 3)
        ring_ff, coeffs_ff = reduce_modulo(coeffs_zz, ring, goodprime)
        isgroebner_f4(ring_ff, exps, coeffs_ff, rng)
    else # if proved result is needed, compute in rationals
        isgroebner_f4(ring, exps, coeffs, rng)
    end
end
