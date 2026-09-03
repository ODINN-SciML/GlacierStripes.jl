export Stripes

function _mean_nonmissing(values)
    valid_values = collect(skipmissing(values))
    return isempty(valid_values) ? NaN : mean(valid_values)
end

function _temporal_series(layer)
    data = parent(layer)
    if ndims(data) == 1
        return Float64.(coalesce.(data, NaN))
    end

    spatial_dims = Tuple(1:(ndims(data) - 1))
    return Float64.(vec(mapslices(_mean_nonmissing, data; dims = spatial_dims)))
end

struct Stripes
    rgi_id::String
    climate_source::Symbol
    MB_source::Symbol
    dates::Vector{Date}
    temperature::Vector{Float64}
    precipitation::Vector{Float64}

    function Stripes(
        rgi_id::String;
        climate_source::Symbol = :ERA5,
        MB_source::Symbol = :WGMS,
        tspan::Tuple{<:Real, <:Real} = (1951.0, 2025.0),
        rgi_paths::Dict{String, String} = get_rgi_paths(),
    )
        rgi_ids = [rgi_id]
        climate_tspan = (Float64(tspan[1]), Float64(tspan[2]))
        params = Sleipnir.Parameters(
            simulation=SimulationParameters(
                climate_data_source=climate_source,
                tspan=climate_tspan,
                multiprocessing=false,
                rgi_paths=rgi_paths,
                use_velocities = false,
                test_mode = true, # Disable multiprocessing
            )
        )
        glaciers = initialize_glaciers(rgi_ids, params)
        climate = glaciers[1].climate.raw_climate
        dates = Date.(collect(dims(climate, Ti)))
        start_date = partial_year(Day, Sleipnir.Float(climate_tspan[1]))
        end_date = partial_year(Day, Sleipnir.Float(climate_tspan[2]))
        selected = findall(start_date .<= dates .<= end_date)
        isempty(selected) && throw(ArgumentError("No climate data found in the requested period."))

        new(
            rgi_id,
            climate_source,
            MB_source,
            dates[selected],
            _temporal_series(climate.temp)[selected],
            _temporal_series(climate.prcp)[selected],
        )
    end
end
