# Changelog

## develcoder 0.6.0

#### Breaking changes

- Add dependency `desc` to `Suggests` because it is used in a vignette.
- Dependency `checkrpkgs`: require minimum version `1.0.0` to depend on
  a stable version.

## develcoder 0.5.0

#### Breaking changes

- Dependency `checkinput`: require minimum version `1.0.0` to depend on
  a stable version.

#### Documentation

- Remove old `NEWS`.
- Section ‘Add package-wide documentation’: put code closer to remarks.

## develcoder 0.4.0

#### Breaking changes

- Dependency `progutils`: increase minimum version from `0.2.0` to
  `0.5.0` to prevent
  [`progutils::create_dir()`](https://jessealderliesten.github.io/progutils/reference/create_dir.html)
  from unsafely returning the working directory if creating the
  directory fails.
- Dependencies `checkinput` and `checkrpkgs`: remove unnecessary
  requirements for a minimum version.

## develcoder 0.3.0

#### Breaking changes

- Add dependencies `revdepcheck` and `xfun` to `Imports` because they
  are used in a vignette to check reverse dependencies.

#### Documentation

- Vignette `Package setup`: remove section ‘Importing packages or
  functions’ because it duplicates section ‘Update dependencies’ from
  the vignette `Package development`.
- Vignette `Package development`: add section ‘Check reverse
  dependencies’.
- Remove the `NEWS` template: looking at real `NEWS` files is much more
  useful.

## develcoder 0.2.0

#### Breaking changes

- Dependencies: increase minimum version of `checkinput` from `0.7.0` to
  `0.8.0`, of `progutils` from `0.0.9` to `0.2.0`, and of `checkrpkgs`
  to `>= 0.9.0` to update argument name `allow_zero` to
  `allow_zero_length`.
