##################################################################
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.

#### set up
# load packages
library(bslib)
library(leaflet)
library(leafpop)
library(mapview)
library(RColorBrewer)
library(scales)
library(sf)
library(shiny)
library(thematic)
library(tidyverse)

mapviewOptions(fgb = FALSE)

# read in data
census <- read_rds("data/census.RDS")
communities <- read_rds("data/communities.RDS")
divvy_demographics <- readRDS("data/divvy_demographics.RDS")
divvy_density <- readRDS("data/divvy_density.RDS")
divvy_stations <- readRDS("data/divvy_stations.RDS") 

income_plots <- readRDS("data/income_plots.RDS")
race_plots <- readRDS("data/race_plots.RDS") 
demographics_plots_no_title <- readRDS("data/demographics_plots_no_title.RDS")

# define color palettes for maps
equiticity_pal <- colorRampPalette(
  colors = c("#FFFFFF", "#c6e5d6", "#3F7B5D", "#234938", "#122F22"))
equiticity_pal2 <- colorRampPalette(colors = c("#c6e5d6"))
divvy_pal <- colorRampPalette(
  colors = c("#c7e4f4", "#5FB3E0", "#005a8b"))

communities_vector <- communities %>% 
  arrange(community)
communities_vector <- communities_vector$community

divvy_stations <- divvy_stations %>% 
  arrange(rollout_year) %>% 
  mutate(rollout_year = factor(rollout_year, ordered = TRUE)) 


##################################################################
#### define UI
ui <- bootstrapPage(
  
  navbarPage(

    ## app title
    "Equiticity Data Dashboard", 
    
    ## Divvy Stations Map
    tabPanel(
      # page title
      "Divvy Stations Map",
      # select year
      fillPage(
        div(
          class="outer",
          tags$style(type = "text/css", "#stations_map {height: calc(100vh - 80px) !important;}"),
          mapviewOutput("stations_map"),
          absolutePanel(
            selectInput(inputId = "year", label = "Select year:",
                        choices = levels(divvy_stations$rollout_year), 
                        selected = "2013",
                        multiple = TRUE),
            top = 75, left = 75, width = 200, class = "panel panel-default", fixed = TRUE, 
            style = "padding: 8px; border-bottom: 1px solid #CCC; background: #5FB3E0; opacity: 1; z-index: 100;"
          )
        )
      )
    ),
    
    ## Divvy Bike Density Map
    tabPanel(
      # page title
      "Divvy Bike Density Map",
      # select year
      div(
        class = "outer",
        tags$style(type = "text/css", "#stations_density_map {height: calc(100vh - 80px) !important;}"),
        absolutePanel(
          span(tags$i(h6("This is a map of all of the Divvy bike stations in Chicago.")), style = "color: #FFFFFF"),
          span(tags$i(h6("You can also click on an individual station (represented by a single point)")), style = "color: #FFFFFF"),
          top = 75, left = 75, width = 200, class = "panel panel-default", fixed = TRUE,
          style = "padding: 8px; border-bottom: 1px solid #CCC; background: #5FB3E0; opacity: 1; z-index: 100;"),
        
        # show map
        mapviewOutput("stations_density_map")
      )
    ), 
   
    ## Chicago demographics page (popup graphs)
    navbarMenu(
      # page title
      "Chicago Demographics Maps",

      tabPanel(
        "Race",
        div(
          class = "outer",
          absolutePanel(
            span(tags$i(h6("This is a map for exploring the racial demographics of communities across Chicago.
                           This map is scaled to the proportion of the community that is White;
                           darker shades of green represent more White neighborhoods while lighter shades of green represent less White neighborhoods.")), style = "color: #FFFFFF"),
            span(tags$i(h6("When hovering over a neighborhood, you will see the name of the neighborhood.")), style = "color: #FFFFFF"),
            span(tags$i(h6("By clicking on a neighborhood, a popup graph will appear, and you will see the racial breakdown of the community area,
                          split into White and non-White groups.")), style = "color: #FFFFFF"),
            span(tags$i(h6("")), style = "color: #FFFFFF"),
            top = 75, left = 75, width = 200, class = "panel panel-default", fixed = TRUE,
            style = "padding: 8px; border-bottom: 1px solid #CCC; background: #5FB3E0; opacity: 1; z-index: 100;"),
          mapviewOutput("race_map", height = 710)
          ),
      ),

      tabPanel(
        "Income",
        div(
          absolutePanel(
            span(tags$i(h6("This is a map for exploring the income demographics of communities across Chicago.
                           This map is scaled to the median income of the community;
                           darker shades of green represent higher-income neighborhoods while lighter shades of green represent lower-income neighborhoods.")), style = "color: #FFFFFF"),
            span(tags$i(h6("By hovering over a neighborhood, you will see the name of the neighborhood.")), style = "color: #FFFFFF"),
            span(tags$i(h6("By clicking on a neighborhood, a popup graph will appear, and you will see the income breakdown of the community area.")), style = "color: #FFFFFF"),
            top = 75, left = 75, width = 200, class = "panel panel-default", fixed = TRUE,
            style = "padding: 8px; border-bottom: 1px solid #CCC; background: #5FB3E0; opacity: 1; z-index: 100;"),
          mapviewOutput("income_map", height = 710)
        )
      )
    ),
    
    ## Exmplore a community
    tabPanel(
      # page title
      "Explore a Community",
      # select community
      sidebarLayout(
        sidebarPanel(
          span(tags$i(h5("This interactive tool allows you to select a Chicago neighborhood and explore
                         the demographics of communities across Chicago. 
                       "))),
          selectInput(inputId = "community", label = "Select community:",
                      choices = c(communities_vector),
                      selected = "Albany Park", multiple = FALSE), 
          plotOutput("plot_select_community", width = "100%"),
          height = 6, width = 6
        ),
        # show map
        mainPanel(mapviewOutput("map_select_community"), width = 6),
      )
    ),
  
    ## About
    tabPanel(
      # page title
      "About",
      fluidPage(
        div(
          # about
          tags$h4("About Project"),
          "This web application provides an exploratory data analysis tool for investigating the inequitable rollout
          and expansion of the Chicago Department of Transportation’s Divvy bike sharing program. This data dashboard
          features a series of interactive maps that connect demographic data from the American Community Survey and
          Divvy bike sharing data from the City of Chicago Data Portal. These visualizations demonstrate how the Divvy bike 
          sharing program is less accessible in lower-income, predominantly non-White communities — in that Divvy bike stations
          were introduced later, there are fewer stations, and there are fewer bikes within a 2-mile radius — in comparison 
          to higher-income, predominantly White communities.", tags$br(), tags$br(),
          "This research project was organized by the ",
          tags$a(href="https://sites.northwestern.edu/mcdc/", "Metropolitan Chicago Data-Science Corps (MCDC),"),
          'which is "a collaboration of community organizations and data science students and experts from multiple Chicago-area 
          universities and colleges" that aims to generate data-driven solutions for problems deemed relevant by the community. I 
          began this project in an MCDC course at Northwestern University during the winter of 2022. Our class worked with ',
          tags$a(href="https://www.equiticity.org/", "Equiticity,"),
          '"a racial equity movement working to improve the lives of Black, Brown and Indigenous people of color by harnessing our 
          collective power through programming and advocating for racial equity, increased mobility and racial justice across the U.S."', tags$br(), tags$br(),
          # background
          tags$h4("Background"),
          'The Federal Highway Administration (FHWA) defines micromobility as "any small, low-speed, human- or electric-powered 
          transportation device, including bicycles, scooters, electric-assist bicycles, electric scooters, and other small, 
          lightweight, wheeled conveyances." Micromobility systems — such as Chicago\'s Divvy bike sharing program — often provide an 
          efficient, cost-effective transportation option for short trips. However, micromobility systems in major cities like 
          Chicago tend to be more concentrated in higher-income, predominantly White communities, perpetuating existing inequities 
          around transportation access for lower-income, predominantly non-White communities.', tags$br(), tags$br(),
          # code
          tags$h4("Code"), 
          "Code and cleaned datasets used to generate this Shiny application are available on ", 
            tags$a(href="https://github.com/alexhanachang/equiticity-viz-and-comm", "GitHub."), tags$br(), tags$br(), 
          # sources
          tags$h4("Sources"),
            tags$b("Divvy data: "), 
              "We explored two datasets involving the Divvy bike sharing program from the City of Chicago Data Portal: (1) ",
              tags$a(href="https://data.cityofchicago.org/Transportation/Divvy-Trips/fg6s-gzvg", '"Divvy Trips"'), 
              "— a dataset of individual Divvy bike sharing trips — and (2) ",
              tags$a(href="https://data.cityofchicago.org/Transportation/Divvy-Bicycle-Stations-Historical/eq45-8inv", '"Divvy Bicycle Stations - Historical"'),
              "— a dataset of the historical availability of bicycles at individual Divvy stations.", tags$br(),
            tags$b("Demographic data: "), 
              "The demographic data used for this project comes from the 2015-2019 American Community Survey (ACS) 5-year data. We accessed this data from ",
              tags$a(href="https://www.nhgis.org/", "the National Historical Geographic Information System (NHGIS),"), 
              tags$a(href="https://data.census.gov/cedsci/", "the U.S. Census Bureau,"), " and",
              tags$a(href="https://datahub.cmap.illinois.gov/dataset/community-data-snapshots-raw-data", "the Chicago Metropolitan Agency for Planning (CMAP) Data Hub."), tags$br(),
            tags$b("Mapping data: "),
              tags$a(href="https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-current-/cauq-8yn6", "Chicago Data Portal."), tags$br(), tags$br(),
          # authors
          tags$h4("Authors"),
            tags$b("Primary author: "),
              "alex hana chang", tags$br(),
              "Northwestern University, Class of 2022", tags$br(),
              tags$a(href="https://github.com/alexhanachang", "alexandrachang2022@u.northwestern.edu"), tags$br(), tags$br(),
            tags$b("Team members: "),
              "Akshya Dhinakaran, Austin Kim, Benedict Jung, Edwin Chalas, Hanyin Wang, Ian Braud, Jordan Parry, 
              Julia Qiu, Kylie Lin, Lauren Chandler-Holtz, Mathew Coble, May Nguyen, Mimi Wang, 
              Nicole Nixon, Olivier Gabison, Riley Harper, Sam Dailley, Sherry Sun", tags$br(),
            tags$b("Mentors: "), 
              "Amanda Stathopoulos, Arend Kuyper, Elisa Borowski, and Jason Soria", tags$br(), tags$br(), tags$br(), tags$br(), 
          style = "overflow-x: scroll; overflow-y: scroll;"
        )
      )
    )
  )
)
    
  


##################################################################
#### define server
server <- function(input, output, session) {

  ## Divvy Stations Map
  stations_reactive <- eventReactive(input$year, {
    # get data
    filter_year <- divvy_stations[divvy_stations$rollout_year %in% c(input$year),]
    # map output
    mapview(communities,
            map.types = "CartoDB.Positron",
            legend = FALSE,
            col.regions = list("#c7e4f4"),
            alpha.regions = 0.25, 
            label = "community", 
            popup = popupTable(
              communities, 
              zcol = c("community", "region", "num_stations")
            )
    ) +
      mapview(filter_year, 
              map.types = "CartoDB.Positron",
              xcol = "lon", ycol = "lat", zcol = "rollout_year", 
              layer.name = "Year of station </br> installation",
              col.regions = divvy_pal,
              alpha.regions = 1,
              color = "white",
              label = "station",
              cex = 4,
              popup = popupTable(
                filter_year,
                zcol = c("station", "community", "rollout_year")
              )
      )
  })    
  output$stations_map <- renderLeaflet({stations_reactive()@map})
  
  ## Divvy Bike Density Map
  output$stations_density_map <- renderLeaflet({
    (mapview(divvy_density,
             map.types = "CartoDB.Positron",
             zcol = "avg_in_2_mi_radius",
             layer.name = "Average number </br> of Divvy bikes in </br> a 2-mile radius",
             col.regions = equiticity_pal,
             alpha.regions = 1,
             popup = popupTable(divvy_density, zcol = c("community", "avg_in_2_mi_radius"))))@map
  })  

  output$race_map <- renderLeaflet({
    mapview(divvy_demographics, 
            map.types = "CartoDB.Positron",
            zcol = "prop_white", 
            layer.name = "Proportion of  </br> population that is </br> White",
            col.regions = equiticity_pal, 
            alpha.regions = 1,
            label = "community",
            popup = popupGraph(race_plots, type = "png", width = 600, height = 400))@map
  })
  
  output$income_map <- renderLeaflet({
    mapview(divvy_demographics, 
            map.types = "CartoDB.Positron",
            zcol = "median_income",
            layer.name = "Median income",
            col.regions = equiticity_pal, 
            alpha.regions = 1,
            label = "community",
            popup = popupGraph(income_plots, type = "png", width = 600, height = 400))@map
  })
  
  # output
  output$race_map_select <- renderLeaflet({
    # get data

    # generate map
    (mapview(communities %>% filter(community == input$community),
             map.types = "CartoDB.Positron",
             # zcol = "prop_white",
             layer.name = "Proportion of  </br> population that is </br> White",
             col.regions = list("#c7e4f4"),
             alpha.regions = 1,
             label = "community",
             popup = popupGraph(race_plots[[((communities %>% st_drop_geometry() %>% filter(communities$community == input$community))[[1]])]],
                                type = "png", width = 600, height = 400)))@map})
  
  

  ## Explore a Community (SIDEBAR PANEL BAR PLOTS)
  community_demographics_reactive <- eventReactive(input$community, {
    # get data
    filter_community <- communities %>% filter(community == input$community)
    # charts output
    demographics_plots_no_title[[((filter_community %>% st_drop_geometry())[[1]])]]
  })
  output$plot_select_community <- renderPlot({community_demographics_reactive()})
  
  ## Explore a Community (MAP)
  community_reactive <- eventReactive(input$community, {
    # get data
    filter_community <- communities %>% filter(community == input$community)
    density_filter_community <- divvy_stations %>% filter(community == input$community)
    # map output
    mapview(filter_community, 
            map.types = "CartoDB.Positron",
            # zcol = "prop_white", 
            layer.name = "Proportion of  </br> population that is </br> White",
            col.regions = list("#c7e4f4"),
            alpha.regions = 1,
            label = "community"
            #     #     popup = popupGraph(income_plots[[((communities %>% st_drop_geometry() %>% filter(community == input$community))[[1]])]], 
            #       #                      type = "png", width = 600, height = 400)
    ) + 
      mapview(density_filter_community,
              map.types = "CartoDB.Positron",
              legend = FALSE,
              xcol = "lon", ycol = "lat", 
              layer.name = "Year of station </br> installation",
              col.regions = list("#005a8b"),
              alpha.regions = 1,
              color = "white",
              label = "station",
              cex = 4,
              popup = popupTable(
                filter_year,
                zcol = c("station", "community", "rollout_year")
              )
      )
  })
  output$map_select_community <- renderLeaflet({community_reactive()@map})
}


##################################################################

# run app 
shinyApp(ui = ui, server = server)







