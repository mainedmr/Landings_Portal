# Welcome

Welcome to the state of Maine Department of Marine Resources Landings Data Portal. This application presents non-confidential landings per year, species, and port in various graphical and tabular formats.

# Caveats/Data Limitations

**Data in this portal is periodically updated and may differ from data shown in other DMR landings documents.**

Landings presented in this portal are split between two data sources:

* `Modern` landings data is presented per year, species, and non-confidential port. Confidential landings are aggregated into the `Other Maine` or `Other County Name` ports.
* `Historic` landings data is available as yearly totals for select species; as such, yearly totals produced by the portal when viewing historic data will likely not equal published landings totals, as some species are excluded.

The portal can be toggled between `Modern` and `Historic` landings using the `Landings Type` drop down menu under `Plot/Table Controls`.

# Portal Description

## Sidebar

The sidebar displays on the left of the portal and contains selectors that allow the user to query landings data. The sidebar is hidden when the `About` tab is active, and can be toggled manually with the `Sidebar On/Off` button in the upper-left.

### Preset queries

The blue `i` button at the top of the sidebar contains preset queries. Choosing one of these queries will set the correct selectors and active tab to display the described results.

### Query selectors

The top panel of the sidebar contains filtering selectors. 

* `Ports` allows landings data to be filtered to one or more ports. Text can be typed into the box to search for a port. Ports can be removed from the filter by clicking the black x next to each port; additionally, filtering by port can be removed by clicking the `Clear Port Selection` button.

* `Species` works similarly to the `Ports` selector, allowing landings data to be filtered by one or more species.

* `Years` filters data to a range of years; a single year's data can be selected by dragging the slider such that both ends are on the same year.

### Plot/Table Controls

The lower panel in the sidebar contains controls for the plot/table output. This panel is only visible when on the `Time Series` and `Grouped Variable` tab. It is hidden when the `Map` tab is active.

* `Display Type` controls whether the query will be output as a table or plot. Table output is interactive, and can be sorted by clicking on the column name.

* `Group by` groups the selected query by a variable, such as species or port.

* `Plot Series` chooses which variable (weight, value, trips, harvesters) to plot; if table output is chosen, the table will by default sort on this column.

### Map Controls

When the `Map` tab is active, the `Plot/Table Controls` panel will be replaced with a `Map Controls` panel containing the following selectors:

* `Map by` chooses the map layer - ports, counties, or lobster zones.

* `Color by` selector chooses which landings variable to use when coloring the map layer.

* `Color Scheme` chooses a color scheme to apply to the layer, based on RColorBrewer schemes. For a full description of the color schemes in the list, see [here](https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/colorPaletteCheatsheet.pdf#page=4)

* `Size Points by` selector is only visible when `Map by` is set to a point layer (ports), and allows the points to be sized by a second variable.

## Tabs

In addition to the `About` tab you are presently reading, three tabs display landings data in various formats:

* `Time Series` - Displays filtered data per year and optionally by a second grouping variable (`Group by` sidebar selector). The display can be toggled between table view and line plot with the `Display Type` selector. If a second grouping variable is selected, multiple series will be shown in the time series based on unique values of the grouping variable within the filtered data. If multiple ports and/or species are selected, the yearly totals are summed across the selected species and ports (unless grouping by species or port).

* `Grouped Variable` - Displays filtered data grouped by a chosen variable and arranged in descending order. Requires that a `Group by` variable is selected. If multiple ports and/or species are selected, the totals are summed across the selected species and ports (unless grouping by species or port). Additionally, landings are summed across the selected year range.

* `Map` - Displays a map of landings per port, county, or lobster zone (`Map by` selector). Hovering over a map feature displays a popup of landings information for that feature. Since only modern landings are presented at the port/county/zone level, the `map` tab is not active when viewing historic landings.

# Technicalities

## Questions/comments

* For questions regarding landings data: [Rob Watts](mailto:rob.watts@maine.gov)
* For questions regarding portal: [Bill DeVoe](mailto:william.devoe@maine.gov)

## Bug Reports/Enhancements

Found a bug or have an idea for an enhancement? [Submit an issue](https://github.com/mainedmr/Landings_Portal/issues)
