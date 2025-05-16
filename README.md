# deloRean: Time Travel for Time Series Data

## Why deloRean?

The deloRean package enables users who work with time series vintages to display time series vintages in a structured and open source way, and automate the "publication" of new versions. In case a user does not want to "publish" the dataset on Github publicly, they can also use deloRean as a local package, and just store datasets in a similar way as online, but without the automated update approach (via GitHub Actions).

## How does it work?

the deloRean package has the following functions (so far): `archive_init`, `archive_import_history` and `dataset_update` (?)

### 1. `archive_init`

By running the `archive_init` function, the package creates an R package like structure, that looks like this:

```
├── .github
│   ├── workflows
│   │   ├── ci.yaml
├── DESCRIPTION
├── NAMESPACE
├── README.md
├── R
│   ├── process_data.R
├── data-raw
│   ├── LAST_UPDATE

```

(Although this is the intended package structure, the files `process_data.R` and the GitHub actions folder and its config, and the LAST_UPDATE file isn't included in the `archive_init` function yet.)

#### Github Actions

The Github Actions (GHA) configuration boilerplate is used primarily to run the `process_data.R` file, which means updating the time series dataset. The Github Action is created to run at certain times, i.e. every 1st of the month (to capture the latest data publications & add the vintages to this repository).

The GHA config runs the latest ubuntu ARM version (ARM was chosen since this requires the least runtime (?)) on a specific alpine image which includes R `devxygmbh/r-alpine:4-3.21`, does a manual checkout of the data repository, adds the important libraries (needed to install the R packages later, i.e. to install gert, we need harfbuzz-dev fribidi-dev). Then, the required R packages to run this boilerplated `process_data.R` are installed. I.e. pak to install the other packages, since they are then installed using devxy binaries, not directly from CRAN. Data.table and gert are needed as they are dependencies for deloRean, and remotes is needed to install deloRean from github.

Then the `process_data.R` script is run, which changes the existing dataset (because there is a new version of the dataset available). This is then added, committed and pushed to the github organisation (opentsi).

#### `LAST_UPDATE`

The `LAST_UPDATE` file is responsible for saving the date, time (in UTC Zulu) when the dataset in the repository was last updated.

#### `process_data.R`

The `process_data.R` file is responsible for the following things:

- checking the actuality of the publication (i.e. checking whether there is a more recent version published than the current one (checks `LAST_UPDATE` for that))
- downloading the data from the public data provider (either with an existing Data Providers API Wrapper, or using R packages, such as httr2 to write your own wrapper)
- processing the data (e.g. transforming the data into a unified format, removing extra variables, etc.)
- writing the data to the file (depends on handling of meta data).

The `archive_init` function helps users with these four steps, by providing a boiler plating of the relevant functions, i.e. checking if an update is needed. Of course deloRean cannot help the user with all the specifics of the data extracting and processing, since those processes are all different.

<!-- TODO: detail more specifically for which parts of the `process_data.R` file we will still boilerplate -->

### 2. `archive_import_history`

This function is responsible for setting up the entire time series dataset and its history, by creating the file `index.csv` in the data-raw folder. The data sourced <!-- TODO: from where? --> is saved by release date and then committed per release date. Thus, when you need to go back to a certain time series version, you can just check out to a specific version, by date of commit (using the Github API).

<!-- @matthias is this all correct -->

### 3. `dataset_update`

<!-- @matthias is this function still up to date? I thought this is just a "wrapper" for the Github Action? -->

## ToDo's/To Discuss:

- Decide on how to or whether to integrate swissdata functions into deloRean. I.e. recommend to users to use certain functions for certain data providers. (and import `library(swissdata)` into the `process_data.R` script?)
- Does the `process_data.R` file always need to run, even if the LAST_UPDATE file shows that there is no update needed? Alternative: checking this in the Github Action, i.e. comparing LAST_UPDATE with the publication date from the public data provider.
- Where should the LAST_UPDATE file be created and written to? Currently the idea is that the file is created in `archive_init` function (since all other files are created in this function), and then the date is written into the file in `archive_import_history` (since the data is initially written here, and so the data & time is based on when this function was executed).
- for minna's trial github actions repository, she needed to enable write access of other users (github actions bot in the gha case) in the repository settings, so that the current GHA template was able to run, and successfully push the changes. How should we deal with this, aka should we tell users they need to configure this independently or can we, as github orga specify that all repos belonging to this orga will have write access for other users.
- should the `process_data.R` script really be a script or should it be an Rmd file, to increase readability?
- how should we integrate the meta information into deloRean. How should this be published? In the same repo, also in the data-raw folder?

<!-- The deloRean R package uses R & Git to manage versioned time series data. -->
<!-- - deloRean is a boilerplate for time series data archives / data archive factory, i.e., it provides automation to create data packages that take care of their versioning such ch.kof.globalbaro.
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
``` -->
