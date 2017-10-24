# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

## [1.8.0] - 2017-10-27
### hubzone-sprint-28
### Added

  - HUB-928
    - Changed testing to for geocoder to use Excon stubs

  - HUB-889
    - Adds in the call to the congressional districts layer.
    - Wraps calls to non-HUBZone layers for a location in a new abstracted method `append_other_information()`, which includes congressional districts and likely_qda

## [1.7.0] - 2017-10-12
### hubzone-sprint-27
### Added
  - HUB-877
    - This ticket adds in the concept of `likely_qda` designations for a location. In HUBZone ETL, a new public view was created that contains declarations and county geometries for all disasters defined in the most recent disaster import table.
    - After checking for HUBZone designations, the API will also check the `likely_qda` table and append these to the response under the following update to the response structure:
    ```
      {
        ...,
        hubzone: [same as before, HUBZone designations go here],
        other_information: {
          alerts: {
            likely_qda_designations: [
              {
                "incident_description": <text description of the disaster>,
                "qda_declaration": <date of disaster declaration>
              }
            ]
          }
        },
        ...
      }
    ```
    - The `likely_qda` designation does not interact with the HUBZone designations at all, either in when designations are checked, or in the response structure.

## [1.6.0] - 2017-10-13
### hubzone-sprint-27
### Added
  - This Changelog
### Fixed

  - HUB-885
    - Fixed failing tests for version controller

  - HUB 859
    - Updated gems and addressed rubocop concerns
