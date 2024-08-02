# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

- Support to global cluster
- Support for monitoring features

## [0.0.7] - 2024-08-01

- Adding the ability to add tags to the cluster, as well as instance_specific_tags.

## [0.0.6] - 2024-07-30

- Fixing a bug, where the db_name is `null` on the secret when the caller doesn't specify a database to be created. In these cases, the default `postgres` value is going to be added.

## [0.0.5] - 2024-07-26

- Adding the ability on the module to create the master user's password, so the caller can choose between providing a password through a Secrets Manager Secret, or let the module create it. 

## [0.0.4] - 2024-06-14

- Changes how the module interact with password for the master user. Instead of generating a password inside of this module, the password is stored in a secret manager, and the secret-id is passed in as a module parameter.

## [0.0.3] - 2024-03-05

- Add support for major version upgrades.


## [0.0.2] - 2023-11-30

- Add support for storage encryption.
- Add support for deletion protection.
- Add support for auto-version upgrades. 


## [0.0.1] - 2023-11-09

### Added

- Add initial module for aurora postgres cluster.

---

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Guiding Principles

- Changelogs are for humans, not machines.
- There should be an entry for every single version.
- The same types of changes should be grouped.
- Versions and sections should be linkable.
- The latest version comes first.
- The release date of each version is displayed.
- Mention whether you follow Semantic Versioning.

Types of changes

- **Added** for new features.
- **Changed** for changes in existing functionality.
- **Deprecated** for soon-to-be removed features.
- **Removed** for now removed features.
- **Fixed** for any bug fixes.
- **Security** in case of vulnerabilities.
