% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mod_subclasse_explorer.R
\name{mod_subclasse_explorer_server}
\alias{mod_subclasse_explorer_server}
\title{subclasse_explorer Server Functions}
\usage{
mod_subclasse_explorer_server(
  id,
  authentification_module,
  api_function_options = list(),
  widget_options = list()
)
}
\arguments{
\item{id}{Internal parameter for {shiny}.}

\item{authentification_module}{Authentification module from this package (\code{\link{mod_authentification_server}})}

\item{api_function_options}{List of options to pass to OntologyApi.search_sub_classes_of from opensilexClientToolsR package (\code{\link[opensilexClientToolsR:OntologyApi]{ search_sub_classes_of }})}

\item{widget_options}{List of options to pass to \code{\link[shiny]{selectInput}}}
}
\value{
A named list with various reactive values
\describe{
 \item{input}{The module input, to be used for binding events}
 \item{options}{The options used to call OntologyApi.search_sub_classes_of }
 \item{selected}{The selection of the shiny::selectInput widget }
 \item{choices}{A named list containing the selection choices} 
 \item{result_df}{A dataframe containing the results of OntologyApi.search_sub_classes_of call}
}
}
\description{
subclasse_explorer Server Functions
}
