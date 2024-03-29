% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mod_factor_level_explorer.R
\name{mod_factor_level_explorer_server}
\alias{mod_factor_level_explorer_server}
\title{factor_level_explorer Server Functions}
\usage{
mod_factor_level_explorer_server(
  id,
  authentification_module,
  api_function_options = list(),
  widget_options = list()
)
}
\arguments{
\item{id}{Internal parameter for {shiny}.}

\item{authentification_module}{Authentification module from this package (\code{\link{mod_authentification_server}})}

\item{api_function_options}{List of options to pass to FactorsApi.search_factor_levels from opensilexClientToolsR package (\code{\link[opensilexClientToolsR:FactorsApi]{ search_factor_levels }})}

\item{widget_options}{List of options to pass to \code{\link[shiny]{selectInput}}}
}
\value{
A named list with various reactive values
\describe{
 \item{input}{The module input, to be used for binding events}
 \item{options}{The options used to call FactorsApi.search_factor_levels }
 \item{selected}{The selection of the shiny::selectInput widget }
 \item{choices}{A named list containing the selection choices} 
 \item{result_df}{A dataframe containing the results of FactorsApi.search_factor_levels call}
}
}
\description{
factor_level_explorer Server Functions
}
