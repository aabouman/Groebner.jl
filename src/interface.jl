
#######################################

"""
    function groebner(
            polynomials;
            reduced=true,
            ordering=:input,
            certify=false,
            forsolve=false,
            linalg=:exact,
            rng=MersenneTwister(42),
            loglevel=.Warn
    )

Computes a Groebner basis of the ideal generated by array `polynomials`.

```jldoctest
using Groebner # hide
using DynamicPolynomials # hide
@polyvar x y    # from DynamicPolynomials.jl
groebner([x^2*y + y, x*y^2 - x])
```

If `reduced` is set, returns reduced basis, which is **unique** (default).

Uses monomial ordering defined on `polynomials` by default.
If `ordering` parameter is explicitly specified, it takes precedence.
Possible orderings to specify are

- :input for taking the input ordering (default)
- :lex for lexicographic
- :deglex for graded lexicographic
- :degrevlex for graded reverse lexicographic

Graded orderings tend to be the fastest.

The algorithm is randomized, meaning the obtained result will be correct with a high probability.
Set `certify` to `true` to obtain the correct result guaranteedly.

Set `forsolve` to `true` to tell the algorithm to automatically select parameters
for producing a basis that further can be used for *solving the input system*. In this case,
the output basis will be in general position in lexicographic monomial order.
The computation will, however, fail, if the input polynomial system is not solvable.

The `linalg` parameter is responsible for linear algebra backend to be used.
Currently, available options are

- `:exact` for exact sparse linear algebra (default)
- `:prob` for probabilistic sparse linear algebra. Tends to be faster

The algorithm depends on randomization heavily. Use `rng` to fix the random number generator.

Verboseness can be tweaked with the `loglevel` parameter (default is that only warnings and errors are shown).

"""
function groebner(
    polynomials::Vector{Poly};
    reduced::Bool=true,
    ordering::Symbol=:input,
    certify::Bool=false,
    forsolve::Bool=false,
    linalg::Symbol=:exact,
    rng::Rng=Random.MersenneTwister(42),
    loglevel::Logging.LogLevel=Logging.Warn
) where {Poly,Rng<:Random.AbstractRNG}

    #= set the logger =#
    prev_logger = Logging.global_logger(ConsoleLogger(stderr, loglevel))

    #= extract ring information, exponents and coefficients
       from input polynomials =#
    # Copies input, so that polynomials would not be changed itself.
    ring, exps, coeffs = convert_to_internal(polynomials, ordering)

    #= check and set algorithm parameters =#
    metainfo = set_metaparameters(ring, ordering, certify, forsolve, linalg, rng)

    #= change input ordering if needed =#
    assure_ordering!(ring, exps, coeffs, metainfo)

    #= compute the groebner basis =#
    if ring.ch != 0
        # if finite field #
        bexps, bcoeffs = groebner_ff(ring, exps, coeffs, reduced, metainfo)
    else
        # if rational coefficients #
        bexps, bcoeffs = groebner_qq(ring, exps, coeffs, reduced, metainfo)
    end

    # ordering in bexps here matches target ordering in metainfo

    #= revert logger =#
    Logging.global_logger(prev_logger)

    # ring contains ordering of computation, it is the requested ordering
    #= convert result back to representation of input =#
    convert_to_output(ring, polynomials, bexps, bcoeffs, metainfo)
end

"""
    function isgroebner(
                polynomials;
                ordering=:input,
                certify=true,
                rng=MersenneTwister(42),
                loglevel=Logging.Warn
    )

Checks if `polynomials` forms a Groebner basis.


```jldoctest
using Groebner # hide
using DynamicPolynomials # hide
@polyvar x y
isgroebner([x^2*y + y, x*y^2 - x])
```

Uses the ordering on `polynomials` by default.
If `ordering` is explicitly specified, it takes precedence.

One may set `certify` to `false` to speed up the computation.
Then the obtained result will be correct with a high probability.

"""
function isgroebner(
    polynomials::Vector{Poly};
    ordering=:input,
    certify::Bool=true,
    rng::Rng=Random.MersenneTwister(42),
    loglevel::LogLevel=Logging.Warn
) where {Poly,Rng<:Random.AbstractRNG}

    #= set the logger =#
    prev_logger = Logging.global_logger(ConsoleLogger(stderr, loglevel))

    #= extract ring information, exponents and coefficients
       from input polynomials =#
    # Copies input, so that polys would not be changed itself.
    ring, exps, coeffs = convert_to_internal(polynomials, ordering)

    #= check and set algorithm parameters =#
    metainfo = set_metaparameters(ring, ordering, certify, false, :exact, rng)
    # now ring stores computation ordering
    # metainfo is now a struct to store target ordering

    #= change input ordering if needed =#
    assure_ordering!(ring, exps, coeffs, metainfo)

    #= compute the groebner basis =#
    if ring.ch != 0
        # if finite field
        # Always returns UInt coefficients #
        flag = isgroebner_ff(ring, exps, coeffs, metainfo)
    else
        # if rational coefficients
        # Always returns rational coefficients #
        flag = isgroebner_qq(ring, exps, coeffs, metainfo)
    end

    #=
    Assuming ordering of `bexps` here matches `ring.ord`
    =#

    #= revert logger =#
    Logging.global_logger(prev_logger)

    flag
end

"""
    function normalform(
                basis,
                tobereduced;
                ordering=:input,
                rng=MersenneTwister(42),
                loglevel=Warn
    )

Computes the normal form of polynomial `tobereduced` w.r.t `basis`.

```julia
@polyvar x y
normalform([x^2 - y, y^2 - 1], x^2 + y^2)
```

The `basis` is assumed to be a Groebner basis.

Uses the ordering on `basis` by default.
If `ordering` is explicitly specified, it takes precedence.

"""
function normalform(
    basis::Vector{Poly},
    tobereduced::Poly;
    ordering::Symbol=:input,
    rng::Rng=Random.MersenneTwister(42),
    loglevel::LogLevel=Logging.Warn
) where {Poly,Rng<:Random.AbstractRNG}

    iszero(tobereduced) && return tobereduced

    first(normalform(
        basis, [tobereduced],
        ordering=ordering, rng=rng, loglevel=loglevel)
    )
end

function normalform(
    basis::Vector{Poly},
    tobereduced::Vector{Poly};
    ordering::Symbol=:input,
    rng::Rng=Random.MersenneTwister(42),
    loglevel::LogLevel=Logging.Warn
) where {Poly,Rng<:Random.AbstractRNG}

    #= set the logger =#
    prev_logger = Logging.global_logger(ConsoleLogger(stderr, loglevel))

    if !isgroebner(basis, certify=false)
        @warn "Input basis does not look like a groebner basis."
    end

    #= extract ring information, exponents and coefficients
       from input basis polynomials =#
    # Copies input, so that polys would not be changed itself.
    ring1, basisexps, basiscoeffs = convert_to_internal(basis, ordering)
    ring2, tbrexps, tbrcoeffs = convert_to_internal(tobereduced, ordering)

    @assert ring1.nvars == ring2.nvars && ring1.ch == ring2.ch
    @assert ring1.ord == ring2.ord

    ring = ring1

    #= check and set algorithm parameters =#
    metainfo = set_metaparameters(ring, ordering, false, false, :exact, rng)

    #= change input ordering if needed =#
    assure_ordering!(ring, basisexps, basiscoeffs, metainfo)
    assure_ordering!(ring, tbrexps, tbrcoeffs, metainfo)


    # We assume basispolys is already a Groebner basis! #

    #= compute the groebner basis =#
    bexps, bcoeffs = normal_form_f4(
        ring, basisexps, basiscoeffs,
        tbrexps, tbrcoeffs, rng)

    #=
    Assuming ordering of `bexps` here matches `ring.ord`
    =#

    #= revert logger =#
    Logging.global_logger(prev_logger)

    # ring contains ordering of computation, it is the requested ordering
    #= convert result back to representation of input =#
    convert_to_output(ring, tobereduced, bexps, bcoeffs, metainfo)
end

"""
    function fglm(
            basis;
            rng=MersenneTwister(42),
            loglevel=Warn
    )

Applies FGLM algorithm to `basis` and returns a Groebner basis in `lex` ordering.

```julia
@polyvar x y
fglm([x^2 - y, y^2 - 1])
```

Assumes `basis` is already a Groebner basis in *some* ordering.

"""
function fglm(
    basis::Vector{Poly};
    rng::Rng=Random.MersenneTwister(42),
    loglevel::Logging.LogLevel=Logging.Warn
) where {Poly,Rng<:Random.AbstractRNG}

    #= set the logger =#
    prev_logger = Logging.global_logger(ConsoleLogger(stderr, loglevel))

    if !isgroebner(basis, certify=false)
        @warn "Input basis does not look like a groebner basis."
    end

    #= extract ring information, exponents and coefficients
       from input polynomials =#
    # Copies input, so that polynomials would not be changed itself.
    ring, exps, coeffs = convert_to_internal(basis, :input)

    metainfo = set_metaparameters(ring, :lex, false, false, :exact, rng)

    bexps, bcoeffs = fglm_f4(ring, exps, coeffs, metainfo)

    # lol
    ring.ord = :lex

    # ordering in bexps here matches target ordering in metainfo

    #= revert logger =#
    Logging.global_logger(prev_logger)

    # ring contains ordering of computation, it is the requested ordering
    #= convert result back to representation of input =#
    convert_to_output(ring, basis, bexps, bcoeffs, metainfo)
end

"""
    function kbase(
            basis;
            rng=MersenneTwister(42),
            loglevel=Warn
    )

Returns the basis of polynomial ring modulo the zero-dimensional ideal
generated by `basis`.

```julia
@polyvar x y
kbase([x^2 - y, y^2 - 1])
```

"""
function kbase(
    basis::Vector{Poly};
    rng::Rng=Random.MersenneTwister(42),
    loglevel::Logging.LogLevel=Logging.Warn
) where {Poly,Rng<:Random.AbstractRNG}

    #= set the logger =#
    prev_logger = Logging.global_logger(ConsoleLogger(stderr, loglevel))

    #= extract ring information, exponents and coefficients
       from input polynomials =#
    # Copies input, so that polynomials would not be changed itself.
    ring, exps, coeffs = convert_to_internal(basis, :input)

    metainfo = set_metaparameters(ring, :input, false, false, :exact, rng)

    bexps, bcoeffs = kbase_f4(ring, exps, coeffs, metainfo)

    # ordering in bexps here matches target ordering in metainfo

    #= revert logger =#
    Logging.global_logger(prev_logger)

    # ring contains ordering of computation, it is the requested ordering
    #= convert result back to representation of input =#
    convert_to_output(ring, basis, bexps, bcoeffs, metainfo)
end
