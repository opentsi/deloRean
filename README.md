# deloRean: Time Travel for Time Series Data 

The deloRean R package uses R & Git to manage versioned time series data. 

- deloRean is a boilerplate for time series data archives / data archive factory, i.e., it provides automation to create data packages that take care of their versioning such ch.kof.globalbaro. 
- deloRean does history altering commits, hence used opentimeseries package to read data from archive. DON'T CLONE data archives.
- if you don't trust the opentimeseries initiative to do vintage updates the way you want, you can use our framework to create your own git based time series archives. 



## Basic Usage - Data Consumers

- most users: use opentimeseries package
- regular GHA runs
- data donations
- opentsi


## Basic Usage - Data Providers

- gives you a toolset to manage different versions of time series using git
- dataset = git repo = same release date
- automate updates with GHA or custom process

### Setting Up a New Archive

1. use boilerplate init_archive
2. import the history of the time series up until that point
3. write update functions, for future regular update tracking



## Installation

Installation of the package is only necessary if you want to operate a time
archive yourself. Currently deloRean is experimental and can be installed
from GitHub with standard R tools for non-CRAN installation. 

using remotes

```r
remotes::install_github("opentsi/deloRean")

```

using devtools

```r
devtools::install_github("opentsi/deloRean")
```




