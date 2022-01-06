install.packages(c('remotes'))
Sys.setenv(TAR = "/bin/tar")
remotes::install_github('OpenSILEX/opensilexClientToolsR', build_vignettes=FALSE, ref='1.0.0')
