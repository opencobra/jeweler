# opencobra/jeweler: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2023-11-21

### Fixed

- Update MEMOTE to version 0.16.1, which enables setting the solver backend before model parsing.
- Set the chosen solver backend before parsing/validating a model from an SBML document. Thus avoiding, for example, GLPK specific problems.

## [1.0.0] - 2023-11-20

Initial release of opencobra/jeweler, created with the [nf-core](https://nf-co.re/) template.
