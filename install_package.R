# Install dependencies
devtools::install_deps("/home/heinrich/code/R-python-opensilex/openshiny/clay_0.0.0.9000.tar.gz",dependencies="logical")
install.packages("/home/heinrich/code/R-python-opensilex/openshiny/clay_0.0.0.9000.tar.gz", type="source", dependencies = TRUE)
remotes::install_local('/home/heinrich/code/R-python-opensilex/openshiny/clay_0.0.0.9000.tar.gz', dependencies=TRUE)