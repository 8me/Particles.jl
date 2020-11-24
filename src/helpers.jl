# Helper functions
# Based on the particle Python package implementations from the SciKit-HEP
# group: https://github.com/scikit-hep/particle/blob/master/src/particle/pdgid/functions.py

"""
    isstandard(p::Union{Particle, PDGID, Integer})

Returns true if the PDG ID of the particle follows the standard numbering scheme.
"""
function isstandard(p)
    p = pdgid(p)
    p.N8 == 0 && p.N9 == 0 && p.N10 == 0
end

"""
    isfundamental(p::Union{Particle, PDGID, Integer})

"""
function isfundamental(p)
    p = pdgid(p)
    !isstandard(p) && return false
    p.Nq2 == 0 && p.Nq1 == 0 && return true
    abs(p.value) <= 100 && return true
    false
end


"""
    fundamentalid(p::Union{Particle, PDGID, Integer})

"""
function fundamentalid(p)
    p = pdgid(p)
    !isstandard(p) && return 0
    abspdgid = abs(p.value)
    p.Nq2 == 0 && p.Nq1 == 0 && return abspdgid % 10000
    abs(p.value) <= 100 && return abspgdid
    0
end


"""
    isquark(p::Union{Particle, PDGID, Integer})

"""
isquark(p) = 1 <= abs(pdgid(p).value) <= 8

"""
    islepton(p::Union{Particle, PDGID, Integer})

"""
function islepton(p)
    p = pdgid(p)
    !isstandard(p) && return false
    11 <= fundamentalid(p) <= 18 && return true
    false
end

"""
    ismeson(p::Union{Particle, PDGID, Integer})

"""
function ismeson(p)
    p = pdgid(p)
    !isstandard(p) && return false

    abspdgid = abs(p.value)

    abspdgid <= 100 && return false
    0 < fundamentalid(p) <= 100 && return false
    # Special IDs - K(L)0, ???, K(S)0
    abspdgid ∈ [130, 210, 310] && return true
    # Special IDs - B(L)0, B(sL)0, B(H)0, B(sH)0
    abspdgid ∈ [150, 350, 510, 530] && return true
    # Special particles - reggeon, pomeron, odderon
    p.value ∈ [110, 990, 9990] && return true

    if p.Nj > 0 && p.Nq3 > 0 && p.Nq2 > 0 && p.Nq1 == 0
        # check for illegal antiparticles
        p.Nq3 == p.Nq2 && p.value < 0 && return false
        return true
    end
    false
end

"""
    isbaryon(p::Union{Particle, PDGID, Integer})

"""
function isbaryon(p)
    p = pdgid(p)
    abspdgid = abs(p.value)

    abspdgid <= 100 && return false

    # Special case of proton and neutron:
    # needs to be checked first since isstandard() is false for nuclei
    abspdgid ∈ [1000000010, 1000010010] && return true

    !isstandard(p) && return false
    0 < fundamentalid(p) <= 100 && return false

    # Old codes for diffractive p and n (MC usage)
    abspdgid ∈ [2110, 2210] && return true

    p.Nj > 0 && p.Nq3 > 0 && p.Nq2 > 0 && p.Nq1 > 0 && return true

    (isRhadron(p) || ispentaquark(p)) && return false

    false
end

"""
    ishadron(p::Union{Particle, PDGID, Integer})

"""
function ishadron(p)
    p = pdgid(p)
    abs(p.value) ∈ [1000000010, 1000010010] && return true
    !isstandard(p) && return false
    ismeson(p) && return true
    isbaryon(p) && return true
    ispentaquark(p) && return true
    isRhadron(p) && return true
    false
end

"""
    isRhadron(p::Union{Particle, PDGID, Integer})

An R-hadron is of the form 10abcdj, 100abcj, or 1000abj,
where j = 2J + 1 gives the spin; b, c, and d are quarks or gluons;
and a (the digit following the zero's) is a SUSY particle.

"""
function isRhadron(p)
    p = pdgid(p)
    !isstandard(p) && return false
    (p.N != 1 || p.Nr != 0) && return false
    isSUSY(p) && return false
    # All R-hadrons have at least 3 core digits
    (p.Nq2 == 0 || p.Nq3 == 0 || p.Nj == 0) && return false
    true
end


"""
    isSUSY(p::Union{Particle, PDGID, Integer})

Fundamental SUSY particles have N = 1 or 2.

"""
function isSUSY(p)
    p = pdgid(p)
    !isstandard(p) && return false
    p.N != 1 && p.N != 2 && return false
    p.Nr != 0 && return false
    fundamentalid(p) == 0 && return false
    true
end


"""
    ispentaquark(p::Union{Particle, PDGID, Integer})

Pentaquark IDs are of the form +/- 9 Nr Nl Nq1 Nq2 Nq3 Nj,
where Nj = 2J + 1 gives the spin and Nr Nl Nq1 Nq2 Nq3 denote the quark numbers
in order Nr >= Nl >= Nq1 >= Nq2 and Nq3 gives the antiquark number.

"""
function ispentaquark(p)
    p = pdgid(p)
    !isstandard(p) && return false
    p.N != 9 && return false
    (p.Nr == 9 || p.Nr == 0) && return false
    (p.Nj == 9 || p.Nl == 0) && return false
    p.Nq1 == 0 && return false
    p.Nq2 == 0 && return false
    p.Nq3 == 0 && return false
    p.Nj == 0 && return false
    p.Nq2 > p.Nq1 && return false
    p.Nq1 > p.Nl && return false
    p.Nl > p.Nr && return false
    true
end

"""
    isgaugebosonorhiggs(p::Union{Particle, PDGID, Integer})

"""
function isgaugebosonorhiggs(p)
    p = pdgid(p)
    21 <= abs(p.value) <= 40
end

"""
    issmgaugebosonorhiggs(p::Union{Particle, PDGID, Integer})
"""
function issmgaugebosonorhiggs(p)
    p = pdgid(p)
    abs(p.value) == 24 || 21 <= p.value <= 25
end


"""
    istechnicolor(p::Union{Particle, PDGID, Integer})
"""
function istechnicolor(p)
    p = pdgid(p)
    !isstandard(p) && return false
    p.N == 3
end

"""
    iscompositequarkorlepton(p::Union{Particle, PDGID, Integer})

Excited (composite) quarks and leptons have N = 4 and Nr = 0.
"""
function iscompositequarkorlepton(p)
    p = pdgid(p)
    !isstandard(p) && return false
    fundamentalid(p) == 0 && return false
    !(p.N == 4 && p.Nr == 0) && return false
    true
end

"""
    isdyon(p::Union{Particle, PDGID, Integer})

Magnetic monopoles and Dyons are assumed to have one unit of Dirac monopole
charge and a variable integer number xyz units of electric charge, where xyz
stands for Nq1 Nq2 Nq3.
Codes 411xyz0 are used when the magnetic and electrical charge sign agree and
412xyz0 when they disagree, with the overall sign of the particle set by the
magnetic charge. For now, no spin information is provided.
"""
function isdyon(p)
    p = pdgid(p)
    !isstandard(p) && return false
    p.N != 4 && return false
    p.Nr != 1 && return false
    !(p.Nl ∈ [1, 2]) && return false
    p.Nq3 == 0 && return false
    p.Nj != 0 && return false
    true
end

"""
    isdiquark(p::Union{Particle, PDGID, Integer})
"""
function isdiquark(p)
    p = pdgid(p)
    !isstandard(p) && return false
    abs(p.value) <= 100 && return false
    0 < fundamentalid(p) <= 100 && return false
    p.Nj > 0 && p.Nq3 == 0 && p.Nq2 > 0 && p.Nq1 > 0 && return true
    false
end

"""
    isgeneratorspecific(p::Union{Particle, PDGID, Integer})

Codes 81-100 are reserved for generator-specific pseudoparticles and concepts.
Codes 901-930, 1901-1930, 2901-2930, and 3901-3930 are for additional components
of Standard Model parton distribution functions, where the latter three ranges
are intended to distinguish left/right/longitudinal components.
Codes 998 and 999 are reserved for GEANT tracking purposes.
"""
function isgeneratorspecific(p)
    p = pdgid(p)
    abspdgid = abs(p.value)
    81 <= abspdgid <= 100 && return true
    901 <= abspdgid <= 930 && return true
    1901 <= abspdgid <= 1930 &&  return true
    2901 <= abspdgid <= 2930 && return true
    3901 <= abspdgid <= 3930 && return true
    abspdgid ∈ [998, 999] && return true
    abspdgid ∈ [20022, 480000000] && return true  # Special cases of opticalphoton and geantino
    false
end


"""
    isspecial(p::Union{Particle, PDGID, Integer})

Special particle in the sense of the classification in the PDG MC particle
numbering scheme document, hence the graviton, the DM (S = 0, 1/2, 1) particles,
the reggeons (reggeon, pomeron and odderon), and all generator-specific
pseudo-particles and concepts, see `isgeneratorspecific`.
"""
function isspecial(p)
    p = pdgid(p)
    p.value ∈ [39, 41, 42, 51, 52, 53, 110, 990, 9990] || isgeneratorspecific(p)
end


"""
    isQball(p::Union{Particle, PDGID, Integer})

Does this PDG ID correspond to a Q-ball or any exotic particle with electric
charge beyond the qqq scheme?
Ad-hoc numbering for such particles is +/- 100XXXY0, where XXX.Y is the charge.
"""
function isQball(p)
    p = pdgid(p)
    p.N8 != 1 && return false
    p.N != 0 && return false
    p.Nr != 0 && return false
    (abs(p.value) ÷ 10) % 10000 == 0 && return false
    p.Nj != 0 && return false
    true
end


"""
    hasfundamentalanti(p::Union{Particle, PDGID, Integer})

If this is a fundamental particle, does it have a valid antiparticle?

Notes
-----
Based on the current list of defined particles/concepts
in the PDG Monte Carlo Particle Numbering Scheme document.

"""
function hasfundamentalanti(p)
    p = pdgid(p)
    fid = fundamentalid(p)  # always a positive integer

    # Check generator-specific PDGIDs
    81 <= fid <= 100 && return fid ∈ [82, 84, 85, 86, 87]

    # Check PDGIDs from 1 to 79
    cp_conjugates = [21, 22, 23, 25, 32, 33, 35, 36, 39, 40, 43]
    unassigned = vcat([9, 10, 19, 20, 26], 26:31, 45:79)  # not in conversion.csv

    if (1 <= fid <= 79) && !(fid ∈ cp_conjugates)
        fid ∈ unassigned && return false
        return true
    end
    false
end


"""
    isnucleus(p::Union{Particle, PDGID, Integer})

Ion numbers are +/- 10LZZZAAAI.
AAA is A - total baryon number
ZZZ is Z - total charge
L is the total number of strange quarks.
I is the isomer number, with I=0 corresponding to the ground state.
"""
function isnucleus(p)
    p = pdgid(p)
    # A proton can be a Hydrogen nucleus
    # A neutron can be considered as a nucleus when given the PDG ID 1000000010,
    # hence consistency demands that isnucleus(neutron) is True
    abs(p.value) ∈ [2112, 2212] && return true

    if p.N10 == 1 && p.N9 == 0
        # Charge should always be less than or equal to the baryon number
        A_ = A(p)
        Z_ = Z(p)

        (isnothing(A_) || isnothing(Z_)) && return false

        A_ >= abs(Z_) && return true
    end
    false
end


"""
    A(p::Union{Particle, PDGID, Integer})

Returns the atomic number A if the PDG ID corresponds to a nucleus, else it
returns `nothing`.
"""
function A(p)
    p = pdgid(p)
    abspdgid = abs(p.value)
    abspdgid ∈ [2112, 2212] && return 1
    (p.N10 != 1 || p.N9 != 0) && return nothing
    (abspdgid ÷ 10) % 1000
end


"""
    Z(p::Union{Particle, PDGID, Integer})

Returns the charge Z if the PDG ID corresponds to a nucleus, else it returns
`nothing`.
"""
function Z(p)
    p = pdgid(p)
    abspdgid = abs(p.value)
    abspdgid == 2212 && return sign(p.value)
    abspdgid == 2112 && return 0
    (p.N10 != 1 || p.N9 != 0) && return nothing
    ((abspdgid ÷ 10000) % 1000) * sign(p.value)
end


"""
    _hasquark(p:::Union{Particle, PDGID, Integer}, q::Integer)

Note that q is always positive, so [1, 6] for Standard Model quarks
and [7, 8] for fourth-generation quarks.
"""
function _hasquark(p, q::Integer)
    p = pdgid(p)
    # Nuclei can also contain strange quarks,
    # cf. the definition of a nucleus PDG ID in isnucleus.
    # This check needs to be done first since _extra_bits(pdgid) > 0 for nuclei
    if isnucleus(p)
        q ∈ [1, 2]  && return true # Nuclei by construction contain up and down quarks
        if q == 3 && !(p.value ∈ [2112, 2212])
            p.N8 > 0 && return true
            return false
        end
    end

    !isstandard(p) && return false
    fundamentalid(p) > 0 && return false
    isdyon(p) && return false

    if isRhadron(p)
        _digits = digits(abs(p.value), pad=10)
        iz = 7
        for loc ∈ range(6, 2; step=-1)
            if _digits[loc] == 0
                iz = loc
            elseif loc == iz - 1
                # ignore squark or gluino
            else
                _digits[loc] == q && return true
            end
        end
        return false
    end

    (p.Nq3 == q || p.Nq2 == q || p.Nq1 == q) && return true

    ispentaquark(p) && (p.Nl == q || p.Nr == q) && return true
    false
end

"""
    hasdown(p::Union{Particle, PDGID, Integer})
"""
hasdown(p) = _hasquark(pdgid(p), 1)

"""
    hasdown(p::Union{Particle, PDGID, Integer})
"""
hasup(p) = _hasquark(pdgid(p), 2)

"""
    hasstrange(p::Union{Particle, PDGID, Integer})
"""
hasstrange(p) = _hasquark(pdgid(p), 3)

"""
    hascharm(p::Union{Particle, PDGID, Integer})
"""
hascharm(p) = _hasquark(pdgid(p), 4)

"""
    hasbottom(p::Union{Particle, PDGID, Integer})
"""
hasbottom(p) = _hasquark(pdgid(p), 5)

"""
    hastop(p::Union{Particle, PDGID, Integer})
"""
hastop(p) = _hasquark(pdgid(p), 6)
