using JSON
using TOML
using Sleipnir
using GlacierStripes

const repo_root = normpath(joinpath(@__DIR__, ".."))
const website_dir = joinpath(repo_root, "website")
const output_dir = joinpath(website_dir, "data")
const image_dir = joinpath(website_dir, "images")
config = TOML.parsefile(joinpath(website_dir, "glaciers.toml"))
ids = String.(config["glaciers"])
generation = config["generation"]
start_year = Float64(generation["start_year"])
end_year = Float64(generation["end_year"])
climate_source = Symbol(generation["climate_source"])
mass_balance_source = Symbol(generation["mass_balance_source"])
mkpath(output_dir)
mkpath(image_dir)

if !isempty(get(ENV, "SLEIPNIR_PREPRO_DIR", ""))
    Sleipnir.prepro_dir = ENV["SLEIPNIR_PREPRO_DIR"]
end
rgi_paths = get_rgi_paths()
catalogue = NamedTuple[]

for rgi_id in ids
    @info "Generating glacier stripes" rgi_id
    stripes = Stripes(rgi_id; climate_source, MB_source = mass_balance_source, tspan = (start_year, end_year), rgi_paths = rgi_paths)
    params = Sleipnir.Parameters(simulation = SimulationParameters(
        climate_data_source = climate_source, tspan = (start_year, end_year),
        multiprocessing = false, rgi_paths = rgi_paths, use_velocities = false, test_mode = true,
    ))
    glacier = initialize_glaciers([rgi_id], params)[1]
    stem = replace(rgi_id, r"[^A-Za-z0-9_.-]" => "_")
    temperature_path = joinpath(image_dir, "$(stem)-temperature.png")
    precipitation_path = joinpath(image_dir, "$(stem)-precipitation.png")
    plot_temperature_stripes(stripes; save_path = temperature_path)
    plot_precipitation_stripes(stripes; save_path = precipitation_path)
    push!(catalogue, (
        rgi_id = rgi_id, name = isempty(glacier.name) ? glacierName(rgi_id) : glacier.name,
        region = startswith(rgi_id, "RGI60-") ? split(split(rgi_id, "-")[2], ".")[1] : "",
        latitude = glacier.cenlat, longitude = glacier.cenlon,
        temperature_image = "images/$(basename(temperature_path))",
        precipitation_image = "images/$(basename(precipitation_path))",
    ))
end

open(joinpath(output_dir, "glaciers.json"), "w") do io
    JSON.print(io, catalogue, 2)
    write(io, '\n')
end
@info "Website data generated" glacier_count = length(catalogue) output_dir