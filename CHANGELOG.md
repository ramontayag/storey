# v0.5.0

- Removed attr_accessors from Storey::Duplicator (they were never meant to be part of the public API anyway)

# v0.4.2

- `rake storey:migrate VERSION=xxxx` now works and uses the `VERSION` environment variable
- `reset_column_information` of all models to avoid strange PostgreSQL errors (see https://github.com/ramontayag/storey/issues/11)
- Add this CHANGELOG :)
