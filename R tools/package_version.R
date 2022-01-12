# Get R version
R.version
# Get all packages and their current version
package_list <- .packages()
for (package in package_list) {
    print(paste(package, ': ' , packageVersion(package)))
}