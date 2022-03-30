
#=
    The file contains the implementation of the FGLM algorithm,
    an algorithm for ordering conversion
=#

mutable struct NextMonomials
    # monomials to check
    monoms::Vector{Int}
    load::Int
    done::Dict{Int, Int}
end

Base.isempty(m::NextMonomials) = m.load == 0

function initialize_nextmonomials(ht)
    vidx = insert_in_hash_table!(ht, zero(ht.exponents[1]))
    monoms = Vector{Int}(undef, 2^3)
    monoms[1] = vidx
    load = 1
    NextMonomials(monoms, load, Dict{Int, Int}(vidx => 1))
end

function insertnexts!(
            m::NextMonomials,
            ht::MonomialHashtable, monom::Int)
    while m.load + ht.nvars >= length(m.monoms)
        resize!(m.monoms, length(m.monoms) * 2)
    end

    emonom = ht.exponents[monom]
    for i in 1:ht.nvars
        eprod = copy(emonom)
        eprod[i] += 1
        eprod[end] += 1
        vidx = insert_in_hash_table!(ht, eprod)

        if !haskey(m.done, vidx)
            m.load += 1
            m.monoms[m.load] = vidx
            m.done[vidx] = 1
        end
    end

    sort_monoms_decreasing!(m.monoms, m.load, ht, :lex)
end

function nextmonomial!(m::NextMonomials)
    # assuming m.monoms is sorted (reversed)
    monom = m.monoms[m.load]
    m.load -= 1
    monom
end

function add_generator!(basis::Basis{C}, matrix, relation, ht) where {C<:Coeff}
    rexps, rcoeffs, _ = extract_sparse_row(relation)

    if debug()
        @warn "add generator"
        println(relation)
        println(rexps, " ", rcoeffs)
    end

    for i in 1:length(rexps)
        rexps[i] = matrix.rightcol2hash[rexps[i]]
    end

    sort_terms_decreasing!(rexps, rcoeffs, ht, :lex)

    if debug()
        @warn "extracted"
        println(rexps)
        println(rcoeffs)
    end

    check_enlarge_basis!(basis, 1)
    basis.ndone += 1
    basis.nlead += 1
    basis.nonred[basis.nlead] = basis.nlead
    basis.gens[basis.ndone] = rexps
    basis.coeffs[basis.ndone] = rcoeffs
end

function divides_staircase(monom, staircase, ht)
    for m in staircase
        if debug()
            @warn "uwu"
            println("is $(ht.exponents[m]) divisible by $(ht.exponents[monom])")
        end
        if is_monom_divisible(monom, m, ht)
            return true
        end
    end
    false
end

#------------------------------------------------------------------------------

function fglm_f4!(
            ring::PolyRing,
            basis::Basis{C},
            ht::MonomialHashtable) where {C<:Coeff}

    newbasis = initialize_basis(ring, basis.ntotal, C)
    nextmonoms = initialize_nextmonomials(ht)
    matrix = initialize_double_matrix(basis)
    staircase = Int[]

    while !isempty(nextmonoms)
        monom = nextmonomial!(nextmonoms)

        if debug()
            @warn "new iteration" ht.exponents[monom]
            @warn "" ht
            println("#############")
            println(nextmonoms)
            println(newbasis.gens, " ", newbasis.coeffs)
        end


        if divides_staircase(monom, staircase, ht)
            continue
        end

        tobereduced    = initialize_basis(ring, [[monom]], [C[1]])
        tobereduced.ntotal = 1

        # compute normal form
        normal_form_f4!(ring, basis, ht, tobereduced)

        if debug()
            println("Normal form ", tobereduced.gens[1], " " ,tobereduced.coeffs[1])
        end

        # matrix left rows can express tobereduced?
        # reduces monom and tobereduced
        exists, relation = linear_relation!(matrix, monom, tobereduced, ht)

        if debug()
            @warn "dump"
            dump(matrix, maxdepth=2)
            println(exists)
        end

        # if linear relation between basis elements exists
        if exists
            lead = ht.exponents[monom]

            if debug()
                @error "produced element" lead
            end

            add_generator!(newbasis, matrix, relation, ht)
            push!(staircase, monom)
        else
            insertnexts!(nextmonoms, ht, monom)
        end
    end

    standardize_basis!(newbasis, ht, :lex)

    newbasis, ht
end

function fglm_f4(
            ring::PolyRing,
            basisexps::Vector{Vector{ExponentVector}},
            basiscoeffs::Vector{Vector{C}},
            rng::Rng) where {Rng, C<:Coeff}

    tablesize = select_tablesize(ring, basisexps)

    basis, ht = initialize_structures(ring, basisexps,
                                        basiscoeffs, rng, tablesize)

    basis, ht = fglm_f4!(ring, basis, ht)

    export_basis_data(basis, ht)
end
