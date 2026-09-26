# Changelog

Changes to the published `alienspacebunny-parent` and `alienspacebunny-build-tools`
artifacts and to the project template. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- `alienspacebunny-parent` manages versions for shared runtime libraries adopted for
  Milton: commonmark-java 0.30.0, JGit 7.8.0 (`org.eclipse.jgit`, `org.eclipse.jgit.ssh.apache`,
  `org.eclipse.jgit.ssh.apache.agent`), JNA 5.19.1 (`jna`, `jna-platform`) and snakeyaml 2.7.
- `micronaut.platform.version` property (5.1.5) recording the Micronaut platform version. The
  Micronaut BOM is not imported, so the parent does not manage Micronaut versions for
  consumers.

### Changed

- Checkstyle now bans direct imports of `org.apache.commons.codec` and
  `org.apache.commons.logging` (along with the existing `sun` ban). They may still
  arrive as transitive dependencies (for example through JGit). Consumers that
  import them fail `verify`.

### Fixed

- `new-project.sh` starts new projects on the newest released `vX.Y.Z` tag rather than
  the `-SNAPSHOT` version in `parent/pom.xml`, which is not on Maven Central.

## [0.1.1] - 2026-09-25

First release published to Maven Central.

### Added

- Project template (`template/`) and `new-project.sh`: a minimal reactor with a `-core`
  module, sample class and test, JaCoCo floor, SpotBugs exclude stub, Maven wrapper,
  pre-push gate hook and AGENTS/CHANGELOG/CHECKPOINT/README stubs.
- maven-release-plugin configuration: all POMs versioned together, tags `v<version>`.
- GitHub **Release** workflow that runs `release:prepare` and deploys the tag to Maven
  Central, with an `existingTag` input to republish a tag after a failed upload.
- `central-release` profile in the parent (sources, javadoc, GPG signing,
  central-publishing-maven-plugin) that consumers inherit for their own releases.
- License and SCM metadata on the published POMs.

### Changed

- `alienspacebunny-build-tools` is a standalone POM, so the aggregator is never
  published.

## [0.1.0] - 2026-09-24

Initial version, installed locally only (not published to Maven Central).

### Added

- `alienspacebunny-parent`: Java 25, plugin version pins, JUnit and Mockito versions,
  enforcer, Spotless, Checkstyle and SpotBugs bound to `verify`, managed JaCoCo.
- `alienspacebunny-build-tools`: shared `alienspacebunny/checkstyle.xml`.

[Unreleased]: https://github.com/AlienSpaceBunny/alienspacebunny-build/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/AlienSpaceBunny/alienspacebunny-build/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/AlienSpaceBunny/alienspacebunny-build/releases/tag/v0.1.0
