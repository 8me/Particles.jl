using Corpuscles
using Test

@testset "Corpuscles.jl" begin

    catalog_files = map(basename, Corpuscles.available_catalog_files())
    @test "particle2019.csv" in catalog_files

    # Particle Identites
    # PDGID <-> Geant3ID 
    geant_id = Geant3ID(1)
    pdg_id = convert(PDGID, geant_id)
    @test isequal(22, pdg_id.value)
    geant_id = Geant3ID(3)
    pdg_id = convert(PDGID, geant_id)
    @test isequal(11, pdg_id.value)
    geant_id = Geant3ID(3)
    pdg_id = convert(PDGID, geant_id)
    @test !isequal(13, pdg_id.value)
    pdg_id = PDGID(22)
    geant_id = convert(Geant3ID, pdg_id)
    @test isequal(1, geant_id.value)
    pdg_id = PDGID(11)
    geant_id = convert(Geant3ID, pdg_id)
    @test isequal(3, geant_id.value)
    pdg_id = PDGID(13)
    geant_id = convert(Geant3ID, pdg_id)
    @test !isequal(1, geant_id.value)
    
    try
        convert(PDGID, Geant3ID(5000))
        @test false
    catch e
        @test e isa Corpuscles.IDException
        msg = sprint(showerror, e)
        @test msg == "ParticleID Error: No corresponding PDGID for Geant3ID(5000) found!"
    end
    
    try
        convert(Geant3ID, PDGID(2222212))
        @test false
    catch e
        @test e isa Corpuscles.IDException
        msg = sprint(showerror, e)
        @test msg == "ParticleID Error: No corresponding Geant3ID for PDGID(2222212) found!"
    end



end
