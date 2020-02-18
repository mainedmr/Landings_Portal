# Welcome

Welcome to the state of Maine Department of Marine Resources Landings Data Portal. This application presents non-confidential landings per year, species, and port in various graphical and tabular formats.

### Portal Description

#### Sidebar

The sidebar displays on the left of the portal and contains selectors that allow the user to query landings data. The sidebar is hidden when the `About` tab is active, and can be toggled manually with the `Sidebar On/Off` button in the upper-left.

##### Preset queries

The blue `i` button at the top of the sidebar contains preset queries. Choosing one of these queries will set the correct selectors and active tab to display the described results.

##### Query selectors

The top panel of the sidebar contains filtering selectors. 

The `Ports` selector allows landings data to be filtered to one or more ports. Text can be typed into the box to search for a port. Ports can be removed from the filter by clicking the black x next to each port; additionally, filtering by port can be removed by clicking the `Clear Port Selection` button.

The `Species` selector works similarly to the `Ports` selector, allowing landings data to be filtered by one or more species.

The `Years` selector filters data to a range of years; a single year's data can be selected by dragging the slider such that both ends are on the same year.

##### Plot/Table Controls

The lower panel in the sidebar contains controls for the plot/table output. This panel is only visible when on the `Time Series` and `Grouped Variable` tab. It is hidden when the `Map` tab is active.

The `Display Type` selector controls whether the query will be output as a table or plot. Table output is interactive, and can be sorted by clicking on the column name.

The `Group by` selector groups the selected query by a variable, such as species or port.

The `Plot Series` selector chooses which variable (weight, value, trips, harvesters) to plot; if table output is chosen, the table will by default sort on this column.

##### Map Controls

When the `Map` tab is active, the `Plot/Table Controls` panel will be replaced with a `Map Controls` panel containing the following selectors:

The `Map by` selector chooses the map layer - ports, counties, or lobster zones.

The `Color by` selector chooses which landings variable to use when coloring the map layer.

The `Color Scheme` selector chooses a color scheme to apply to the layer, based on RColorBrewer schemes. For a full description of the color schemes in the list, see [here](https://www.nceas.ucsb.edu/~frazier/RSpatialGuides/colorPaletteCheatsheet.pdf#page=4)

The `Size Points by` selector is only visible when `Map by` is set to a point layer (ports), and allows the points to be sized by a second variable.

#### Tabs

In addition to the `About` tab you are presently reading, three tabs display landings data in various formats:

* **Time Series** - Displays filtered data per year and optionally by a second grouping variable (`Group by` sidebar selector). The display can be toggled between table view and line plot with the `Display Type` selector. If a second grouping variable is selected, multiple series will be shown in the time series based on unique values of the grouping variable within the filtered data. If multiple ports and/or species are selected, the yearly totals are summed across the selected species and ports (unless grouping by species or port).

* **Grouped Variable** - Displays filtered data grouped by a chosen variable and arranged in descending order. Requires that a `Group by` variable is selected. If multiple ports and/or species are selected, the totals are summed across the selected species and ports (unless grouping by species or port). Additionally, landings are summed across the selected year range.

* **Map** - Displays a map of landings per port, county, or lobster zone (`Map by` selector). Hovering over a map feature displays a popup of landings information for that feature.






