library(opensilexClientToolsR)
library(data.table)
#' overview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_overview_ui <- function(id) {
  ns <- NS(id)
  print(getwd())
  fluidRow(
    shiny::includeCSS("inst/app/www/overview.css"),
    DT::dataTableOutput(ns('datatable')),
    shiny::verbatimTextOutput(ns("terminal")),
    column(
      6,
      h4("Pie chart"),
      shiny::helpText("Number of scientific objects per experiments"),
      div(
        class = "relative",
        div(
          class = "absolute",
          h6("Scale metric"),
          shinyWidgets::switchInput(
            ns("log_scale"),
            onLabel = "Log scale",
            offLabel = "Linear scale",
            value = FALSE,
            inline = TRUE
          )
        ),
        shiny::plotOutput(ns("pie_chart"))
      )
    ),
    column(
      6,
      h4("Barplot"),
      shiny::helpText("Number of scientific object per experiments, per scientific object type"),
      div(
        class = "relative",
        div(
          class = "absolute",
          style = "right: 10px",
          h6("Scale metric"),
          shinyWidgets::switchInput(
            ns("log_scale_barplot"),
            onLabel = "Log scale",
            offLabel = "Linear scale",
            value = FALSE,
            inline = TRUE
          )
        ),
        shiny::plotOutput(ns("barplot"))
      )
    ),
    # column(
    #   6,
    #   h4("Data barplot"),
    #   shiny::helpText("Number of data per experiments"),
    #   div(
    #     class = "relative",
    #     div(
    #       class = "absolute",
    #       style = "right: 10px",
    #       h6("Scale metric"),
    #       shinyWidgets::switchInput(
    #         ns("log_scale_data_barplot"),
    #         onLabel = "Log scale",
    #         offLabel = "Linear scale",
    #         value = FALSE,
    #         inline = TRUE
    #       )
    #     ),
    #     shiny::plotOutput(ns("data_barplot"))
    #   )
    # )
  )
}
    
#' overview Server Functions
#'
#' @noRd 
mod_overview_server <- function(id, authentification_module){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    # Retrieve all experiments
    experiment_dt <- shiny::reactive({
      authentification_module$connect()
      experimentsApi <- opensilexClientToolsR::ExperimentsApi$new()
      result <- experimentsApi$search_experiments()$data
      result_df <- clay::EnvironmentList_to_dataframe(result)
      data.table::data.table(result_df)
    })
  
    so_types_per_experiment <- shiny::reactive({
      experiments_uri <- experiment_dt()$uri
      result_list <- list()
      type_uri_per_experiment <- list()
      authentification_module$connect()
      scientificObjectsApi <- opensilexClientToolsR::ScientificObjectsApi$new()
      for (uri in experiments_uri) {
        so_types <- tryCatch(
          {
            scientificObjectsApi$get_used_types(experiment = uri)$data
          },
          error=function(cond) {
            # Choose a return value in case of error
            return(NULL)
          },
          warning=function(cond) {
            message(paste("URL caused a warning:", url))
            message("Here's the original warning message:")
            message(cond)
            # Choose a return value in case of warning
            return(NULL)
          }
        )    
        # so_types <- scientificObjectsApi$get_used_types(experiment = uri)$data
        if (!is.null(so_types)) {

          so_types_df <- clay::EnvironmentList_to_dataframe(so_types)$name
          result_list[[uri]] <- paste(so_types_df, collapse = ", ")
          so_uri_types_df <- clay::EnvironmentList_to_dataframe(so_types)$uri
          print(as.character(so_uri_types_df))
          type_uri_per_experiment[[uri]] <- as.character(so_uri_types_df)
        }
      }
      mat <- cbind(names(result_list), unlist(unname(result_list)))
      colnames(mat) <- c('uri', 'so_type')
      so_types_DT <- data.table::data.table(mat)
      list(so_types_DT = so_types_DT, type_uri_per_experiment = type_uri_per_experiment)
    })
    
    so_card_per_experiment <- shiny::reactive({
      experiments_uri <- experiment_dt()$uri
      result_list <- list()
      authentification_module$connect()
      scientificObjectsApi <- opensilexClientToolsR::ScientificObjectsApi$new()
      for (uri in experiments_uri) {
        so_count <- tryCatch(
          {
            data <- scientificObjectsApi$search_scientific_objects(experiment = uri, page_size = 1)
            data$metadata$pagination$totalCount
          },
          error=function(cond) {
            # Choose a return value in case of error
            return(NULL)
          },
          warning=function(cond) {
            message(paste("URL caused a warning:", url))
            message("Here's the original warning message:")
            message(cond)
            # Choose a return value in case of warning
            return(NULL)
          }
        )    
        # so_types <- scientificObjectsApi$get_used_types(experiment = uri)$data
        if (!is.null(so_count)) {
          # so_types_df <- clay::EnvironmentList_to_dataframe(so_types)$name
          result_list[[uri]] <- so_count
        }
      }
      mat <- cbind(names(result_list), unlist(unname(result_list)))
      colnames(mat) <- c('uri', 'so_count')
      so_card_DT <- data.table::data.table(mat)
      so_card_DT$so_count <- as.numeric(so_card_DT$so_count)
      so_card_DT
    })
    
    so_card_per_type_per_experiment <- shiny::reactive({
      print("at start from so_card_per_type_per_experiment")
      experiments_dt <- experiment_dt()
      so_types_per_experiment <- so_types_per_experiment()$type_uri_per_experiment
      print(so_types_per_experiment)
      final_df <- data.frame()
      scientificObjectsApi <- opensilexClientToolsR::ScientificObjectsApi$new()
      for (uri in names(so_types_per_experiment)) {
        types_uri <- so_types_per_experiment[[uri]]
        for (type_uri in types_uri) {
          so_count <- tryCatch({
            data <- scientificObjectsApi$search_scientific_objects(experiment = uri, rdf_types = type_uri, page_size = 1)
            print(data)
            data$metadata$pagination$totalCount
          },
          error = function(cond) {
            message("error")
            # Choose a return value in case of error
            return(NULL)
          },
          warning = function(cond) {
            # Choose a return value in case of warning
            return(NULL)
          })
          
          if (!is.null(so_count)) {
            tmp <- uri
            sub_exp <- subset(experiments_dt, uri == tmp)
            ## Should better use an apiCall result, but ...
            inferred_so_type_name <- strsplit(type_uri, "#")[[1]][2]
            to_insert <-
              list(
                experiment_uri = uri,
                experiment_name = sub_exp$name[1],
                so_type = type_uri,
                so_type_name = inferred_so_type_name,
                number = so_count
              )
            final_df <- rbind(final_df, data.frame(to_insert))
          }
        }
      }
      
      final_dt <- data.table(final_df)
      final_dt
    })


    dataCount_per_experiment <- shiny::reactive({
      experiments_dt <- experiment_dt()
      experiments_uri <- experiments_dt$uri
      authentification_module$connect()
      result_list <- list()
      dataApi <- opensilexClientToolsR::DataApi$new()
      for (uri in experiments_uri) {
        print(uri)
        data_count <- tryCatch(
          {
            data <- dataApi$search_data_list(experiments = uri, page_size = 1)
            print(data)
            data$metadata$pagination$totalCount
          },
          error=function(cond) {
            # message(paste("URL caused a error:", url))
            message("Here's the original error message:")
            message(cond)
            # Choose a return value in case of error
            return(NULL)
          },
          warning=function(cond) {
            # message(paste("URL caused a warning:", url))
            message("Here's the original warning message:")
            message(cond)
            # Choose a return value in case of warning
            return(NULL)
          }
        )   
        print(data_count)
        if (!is.null(data_count)) {
          result_list[[uri]] <- data_count
        }
      }
      print("End of data count")
      print(result_list)
      mat <- cbind(names(result_list), unlist(unname(result_list)))
      print(mat)
      colnames(mat) <- c('uri', 'data_count')
      data_card_DT <- data.table::data.table(mat)
      data_card_DT$data_count <- as.numeric(data_card_DT$data_count)
      data_card_DT <-  merge(experiment_dt, data_card_DT, by = 'uri')
      data_card_DT
    })
    
    output$datatable <- DT::renderDataTable({
      print("started rendertable")
      experiment_dt <- experiment_dt()
      so_types_per_experiment <- so_types_per_experiment()
      so_types_DT <- so_types_per_experiment$so_types_DT
      so_card_per_experiment <- so_card_per_experiment()
      data.table::setkey(experiment_dt, "uri")
      data.table::setkey(so_types_DT, "uri")
      data.table::setkey(so_card_per_experiment, "uri")
      full_dt <- Reduce(
        function(x, y, ...) merge(x, y, all = TRUE, ...),
        list(experiment_dt, so_types_DT, so_card_per_experiment)
      )
      
      setcolorder(full_dt, c("name", "start_date", "end_date"))
    },
    options = list(scrollX = TRUE))
    
    # output$terminal <- shiny::renderPrint({
    #   print("started rendertable")
    #   experiment_dt <- experiment_dt()
    #   experiment_dt <- data.table::data.table(experiment_df)
    #   so_types_per_experiment <- so_types_per_experiment()
    #   # # required as, for some very obscur reason, uri is a list
    #   mat <- cbind(names(result_list), unlist(unname(result_list)))
    #   colnames(mat) <- c('uri', 'so_type')
    #   so_types_DT <- data.table::data.table(mat)
    #   print("is.data.table(so_types_DT)")
    #   print(is.data.table(so_types_DT))
    #   data.table::setkey(experiment_dt, "uri")
    #   data.table::setkey(so_types_DT, "uri")
    #   merge(experiment_dt, so_types_DT, all = TRUE)
    # })
    
    output$pie_chart <- shiny::renderPlot({
      authentification_module$connect()
      so_card_per_experiment <- so_card_per_experiment()
      experiment_dt <- experiment_dt()
      full_dt <- merge(experiment_dt, so_card_per_experiment, by = 'uri')
      total <- sum( as.numeric(full_dt$so_count))
      # := data.table syntax doesn't work "here"
      full_dt$so_percent <- as.numeric(full_dt$so_count)/total
      full_dt$label <- paste(full_dt$name, ' ( #', full_dt$so_count, ')')
      data.table::copy(data.table::setorder(full_dt, -so_count))
      bp<- ggplot2::ggplot(full_dt, ggplot2::aes(x="", y=so_count, fill=label))+
        ggplot2::geom_bar(width = 1, stat = "identity") + ggplot2::coord_polar("y", start=0) + ggplot2::theme_void()
      if (input$log_scale) {
        bp <- bp + ggplot2::scale_y_continuous(trans='log2')
      }
      bp
    })
    
    output$barplot <- shiny::renderPlot({
      authentification_module$connect()
      experiment_dt <- experiment_dt()
      so_card_per_type_per_experiment <- so_card_per_type_per_experiment()
      bp<- ggplot2::ggplot(so_card_per_type_per_experiment, ggplot2::aes(x=experiment_name, y=number, fill=so_type_name))+
        ggplot2::geom_bar(stat = "identity") + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, vjust = 1, hjust=1))
      if (input$log_scale_barplot) {
        bp <- bp + ggplot2::scale_y_continuous(trans='log2')
      }
      bp
    })
    
    output$data_barplot <- shiny::renderPlot({
      authentification_module$connect()
      experiment_dt <- experiment_dt()
      data_card_DT <- data_per_experiment()
      bp<- ggplot2::ggplot(data_card_DT, ggplot2::aes(x=experiment_name, y=data_count))+
        ggplot2::geom_bar(stat = "identity") + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, vjust = 1, hjust=1))
      if (input$log_scale_data_barplot) {
        bp <- bp + ggplot2::scale_y_continuous(trans='log2')
      }
      bp
    })
    
    
    
  })
}
    
## To be copied in the UI
# mod_overview_ui("overview_ui_1")
    
## To be copied in the server
# mod_overview_server("overview_ui_1")
