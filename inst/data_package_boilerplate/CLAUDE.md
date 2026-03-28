# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```r
# Install dependencies
pak::pkg_install("opentsi/opentimeseries")

# Document (regenerate NAMESPACE and Rd files)
devtools::document()

# Install the package locally
devtools::install()

# Validate metadata
deloRean::validate_metadata()
```

## Architecture

This package follows the OpenTSI archive pattern:

- **`R/handle_update.R`** — Entry point called by CI. Calls `generate_checksum_input()` to detect whether new data is available, then calls `process_data()` and stores the new checksum via `opentimeseries::update_checksum()`.
- **`R/process_data.R`** — Stub: downloads data from the original provider, writes it to `series.csv` format using `opentimeseries::key_to_path`, and updates the catalog.
- **`data-raw/metadata.yaml`** — Dataset metadata in the OpenTSI schema. Key pattern: `country.provider.dataset.dimension.variable.unit`. The `update_checksum` field at the bottom is managed programmatically.
- **`inst/boilerplate.R`** — Reference script for one-time archive initialization and bulk history import using `deloRean::archive_init()`, `deloRean::create_vintage_dt()`, and `deloRean::archive_import_history()`.

### Update Flow

```
handle_update()
  └── generate_checksum_input()   # user-defined: returns publication date or single series
  └── is_update_needed()          # opentimeseries: compares against stored checksum
  └── update_checksum()           # opentimeseries: writes new checksum to metadata.yaml
  └── process_data()              # user-defined: fetch → csv → catalog update
```

### CI

`.github/workflows/update_data.yaml` runs `handle_update()` on a schedule (`0 10 1,5,15 * *`) and on manual dispatch, then commits any changed data files back to the repo.

## Implementation Status

Both `generate_checksum_input()` and `process_data()` are empty stubs that must be implemented before the package is functional. The `boilerplate.R` script shows the patterns used for the one-time history import (already completed for this archive).

## To Dos
i want you to create this data repository, based on the intial boilerplate given,

and based on other existing data packages of this form given. For this, look at the following remote packages:

- https://github.com/minnaheim/us.fred.indpro
- https://github.com/minnaheim/ch.kof.barometer
- https://github.com/minnaheim/ch.kof.globalbaro


the only thing that's different here is the new function `archive_seal` that has been newly added, and currently is only implemented in the us.fred.indrpo package.

for more information about the setup of the data repositories, please check the vignettes folder in the deloRean package (see: https://github.com/opentsi/deloRean) and you can also check the package opentimeseries at https://github.com/opentsi/opentimeseries

please start by finishing the commands in boilerplate.R (reference /ch.kof.barometer and /ch.kof.globalbaro to see what has been done there and apply the fundamentals to this dataset.)

To solve this task, you dont need to look at my other directories, just the remote github packages.