# Agent Instructions: __NAME__

## Build / Validation Gate

- Java 25, Maven 3.9.16+ via `./mvnw`. Build settings are inherited from
  `com.alienspacebunny:alienspacebunny-parent` (`../alienspacebunny-build`); on a
  fresh machine run `mvn install` there first.
- Run `./mvnw verify` before finishing code changes. It runs tests, the JaCoCo
  coverage floor, Spotless (Palantir Java Format), Checkstyle and SpotBugs.
- Run `./mvnw spotless:apply` to format; don't hand-format.
- Checkstyle rules are the shared `alienspacebunny/checkstyle.xml` (wildcard imports
  banned). SpotBugs exclusions live in `config/spotbugs-exclude.xml`; keep them
  narrow and justified.
- Tool and plugin versions are pinned in the parent. Bump them there, not here.
- Enable the pre-push gate with `git config core.hooksPath .githooks`.

## Changelog and versions

- Record user-facing changes under `## [Unreleased]` in `CHANGELOG.md`, in the same
  commit as the change.
- `main` carries a `-SNAPSHOT` version. Bump the patch version once per substantial
  completed change with
  `./mvnw versions:set -DnewVersion=X.Y.Z-SNAPSHOT -DgenerateBackupPoms=false`.

## Docs

- `CHECKPOINT.md` is the rolling status/resume note; keep it current at the end
  of a session.
