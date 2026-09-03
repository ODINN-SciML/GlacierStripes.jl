export plot_temperature_stripes, plot_precipitation_stripes

function _decimal_year(date::Date)
	date_year = year(date)
	days_in_year = isleapyear(date_year) ? 366 : 365
	return date_year + (dayofyear(date) - 1) / days_in_year
end

function _aggregate_stripes(dates::Vector{Date}, values::Vector{Float64}, frequency::Symbol)
	frequency in (:year, :month) || throw(ArgumentError("frequency must be :year or :month"))
	periods = frequency == :year ? Date.(year.(dates), 1, 1) : Date.(year.(dates), month.(dates), 1)
	unique_periods = unique(periods)
	if frequency == :year
		complete_years = [period for period in unique_periods if
			length(unique(month.(dates[periods .== period]))) == 12]
		isempty(complete_years) && throw(ArgumentError("No complete years found in the selected climate period."))
		unique_periods = complete_years
	end
	aggregated_values = [mean(values[periods .== period]) for period in unique_periods]
	return unique_periods, Float64.(aggregated_values)
end

function _plot_stripes(stripes::Stripes, dates::Vector{Date}, values::Vector{Float64};
	colormap, colorrange, title, colorbar_label,
	save_path = nothing, figure = CairoMakie.Figure())
	year_positions = _decimal_year.(dates)
	date_edges = if length(year_positions) == 1
		[year_positions[1] - 0.5, year_positions[1] + 0.5]
	else
		midpoints = (year_positions[1:(end - 1)] + year_positions[2:end]) ./ 2
		vcat(
			year_positions[1] - (midpoints[1] - year_positions[1]),
			midpoints,
			year_positions[end] + (year_positions[end] - midpoints[end]),
		)
	end
	axis = CairoMakie.Axis(
		figure[1, 1],
		title = title,
		yticks = ([1], [""]),
		xtickformat = values -> string.(round.(Int, values)),
		xlabel = "Year",
		ylabel = "",
	)
	CairoMakie.heatmap!(axis, date_edges, [0.5, 1.5], reshape(values, :, 1);
		colormap = colormap, colorrange = colorrange)
	CairoMakie.Colorbar(
		figure[1, 2];
		colormap = colormap,
		colorrange = colorrange,
		label = colorbar_label,
	)
	CairoMakie.hidespines!(axis, :t, :r, :l, :b)
	CairoMakie.hideydecorations!(axis)
	if !isnothing(save_path)
		CairoMakie.save(save_path, figure)
	end
	return figure
end

function plot_temperature_stripes(stripes::Stripes;
		frequency = :year, colormap = :vik, colorrange = nothing,
		title = nothing, colorbar_label = "Temperature (°C)",
		save_path = nothing, figure = CairoMakie.Figure())
    title = isnothing(title) ? "Temperature over $(glacierName(stripes.rgi_id)) glacier" : title
	dates, values = _aggregate_stripes(stripes.dates, stripes.temperature, frequency)
	colorrange = isnothing(colorrange) ? extrema(values) : colorrange
	return _plot_stripes(
		stripes,
		dates,
		values;
		colormap,
		colorrange,
		title,
		colorbar_label,
		save_path,
		figure,
	)
end

function plot_precipitation_stripes(stripes::Stripes;
		frequency = :year, colormap = :Blues, colorrange = nothing,
		title = nothing, colorbar_label = "Precipitation (m / day)",
		save_path = nothing, figure = CairoMakie.Figure())
    title = isnothing(title) ? "Precipitation over $(glacierName(stripes.rgi_id)) glacier" : title
	dates, values = _aggregate_stripes(stripes.dates, stripes.precipitation, frequency)
	colorrange = isnothing(colorrange) ? extrema(values) : colorrange
	return _plot_stripes(
		stripes,
		dates,
		values;
		colormap,
		colorrange,
		title,
		colorbar_label,
		save_path,
		figure,
	)
end
