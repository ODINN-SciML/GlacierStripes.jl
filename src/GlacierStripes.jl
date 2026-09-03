__precompile__() # this module is safe to precompile
module GlacierStripes

# ##############################################
# ###########       PACKAGES     ##############
# ##############################################

using Base: @kwdef
using Infiltrator
import Pkg
using Pkg.Artifacts
using Statistics, NaNStatistics
using CairoMakie
using Observables
import Contour
using HDF5
using ComponentArrays
using Rasters
import NCDatasets
using CoordRefSystems
using Dates, DateFormats
using DataStructures
using Printf
using CFTime
using Sleipnir

##############################################
############    PARAMETERS     ###############
##############################################

const src_dir::String = dirname(@__FILE__)

##############################################
##########  SLEIPNIR LIBRARIES  ##############
##############################################

include(src_dir*"/setup/config.jl")

include(src_dir*"/stripes/Stripes.jl")
include(src_dir*"/plots/plot_utils.jl")

# # All parameters needed for the models
# include(src_dir*"/parameters/Parameters.jl")

# # Anything related to managing glacier topographical and climate variables
# include(src_dir*"/glaciers/glacier/Glacier.jl")

# # The utils of surface velocity data, glaciers and climate need the struct to be already
# # defined since they depend on each other. This is why we import them afterwards
# include(src_dir*"/glaciers/data/SurfaceVelocityData_utils.jl")
# include(src_dir*"/glaciers/data/SurfaceVelocityMapping_utils.jl")
# include(src_dir*"/glaciers/glacier/glacier2D_topography.jl")
# include(src_dir*"/glaciers/glacier/glacier2D_projection.jl")
# include(src_dir*"/glaciers/glacier/glacier2D_geodata.jl")
# include(src_dir*"/glaciers/glacier/glacier2D_utils.jl")
# include(src_dir*"/glaciers/climate/climate2D_utils.jl")

# # All structures and functions related to ODINN models
# include(src_dir*"/models/Model.jl")

# # Everything related to running simulations in ODINN
# include(src_dir*"/simulations/Simulation.jl")
# # Law interface and utils
# include(src_dir*"/laws/GenInput.jl")
# include(src_dir*"/laws/Inputs.jl")
# include(src_dir*"/laws/Cache.jl")
# include(src_dir*"/laws/AbstractLaw.jl")
# include(src_dir*"/laws/VJP.jl")
# include(src_dir*"/laws/Law.jl")

# # Fake data used in the tests
# include(src_dir*"/data/surface_velocity.jl")

# # Abstract loss definition
# include(src_dir*"/losses/Losses.jl")

##############################################
#######    PRE-LOADED VARIABLES     ##########
##############################################

end # module
