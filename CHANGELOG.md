# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Fixed
- Do not blow up `rake db:create` in Rails 5.2

## [2.0.0]
### Added
- Rails 5 support
- Add ability to get the current schema as an array of strings (`array: true`)
- Fix specs where PG may or may not return the schemas as with leading spaces (`public, foo,bar`)

### Changed
- Removed support for Rails 3, 4 and Ruby 2.3. They are no longer tested.
- Test against Ruby 2.5.0

### Fixed
- Fixed dumping of sql files when pg host is remote

## [1.0.0]
### Added
- It's already being used in production. About time for a 1.0.0 release.

## [0.6.0]
### Changed
- Relax pg version dependency. Works with `~> 0.12`

## [0.5.1]
### Changed
- Relax Rails version dependency. Works with `4.0`.

## [0.5.0]
### Changed
- Removed attr_accessors from Storey::Duplicator (they were never meant to be part of the public API anyway)
- Validate the schema name when creating schemas
- Clean source and target files after duplicating [#18](https://github.com/ramontayag/storey/issues/18)

## [0.4.2]
### Added
- `rake storey:migrate VERSION=xxxx` now works and uses the `VERSION` environment variable
- `reset_column_information` of all models to avoid strange PostgreSQL errors (see https://github.com/ramontayag/storey/issues/11)
- Add this CHANGELOG :)
