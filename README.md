# AlienSpaceBunny shared config

This module contains shared maven config and shared build tools for AlienSpaceBunny Java projects
(rv32ima-java, emulator, alkali, kblock), plus a template for new ones.

| Path | Artifact | Purpose |
|---|---|---|
| `parent/` | `com.alienspacebunny:alienspacebunny-parent` (pom) | Java 25, plugin pins, JUnit/Mockito versions, enforcer, Spotless/Checkstyle/SpotBugs bound to `verify`, managed JaCoCo |
| `build-tools/` | `com.alienspacebunny:alienspacebunny-build-tools` (jar) | Shared `alienspacebunny/checkstyle.xml`, loaded from the Checkstyle plugin classpath |
| `template/` + `new-project.sh` | — | Skeleton for a new project on the current parent |

Nothing is published to a remote repository. Install locally before building any
consumer:

```bash
mvn install
```

## Using the parent

```xml
<parent>
    <groupId>com.alienspacebunny</groupId>
    <artifactId>alienspacebunny-parent</artifactId>
    <version>0.1.0</version>
    <relativePath/>
</parent>
```

Override points (properties), documented at the top of `parent/pom.xml`:

- `asb.config.dir`: the per-repo config directory (default `<reactor root>/config`)
- `asb.checkstyle.config`: default is the shared rules. alkali uses its own because
  ANTLR sources need wildcard imports; rv32ima-java uses its own smaller set.
- `asb.spotbugs.exclude`: default `${asb.config.dir}/spotbugs-exclude.xml`
- `coverage.line.minimum` / `coverage.branch.minimum`: floors for modules that
  declare `jacoco-maven-plugin`

To add to a list setting instead of replacing it, e.g. an extra source root, use
`combine.children="append"` (see emulator's root POM for JMH sources and `requireOS`).

## Updating a version (goal: one place)

1. Edit the pin in `parent/pom.xml` (or the rules in `build-tools/`).
2. Bump this repository's version. `build-tools` and `parent` always share it,
   and the parent refers to build-tools through a property, so set both:
   ```bash
   mvn versions:set -DnewVersion=0.1.1
   mvn -pl parent versions:set-property -Dproperty=asb.build-tools.version -DnewVersion=0.1.1
   mvn install
   ```
   Use release versions only (no `-SNAPSHOT`), so consumer builds stay reproducible.
3. In each consumer, then run `./mvnw spotless:apply verify`:
   ```bash
   ./mvnw versions:update-parent -DparentVersion=0.1.1 -DgenerateBackupPoms=false
   ```
   A formatter bump usually changes source layout. Commit that reformat together
   with the parent bump.

## New project (goal: quick bootstrap)

```bash
./new-project.sh <artifactId> <java.package> ["Display Name"] [target-dir]
# e.g. ./new-project.sh widget com.alienspacebunny.widget "Widget"
```

This creates `../<artifactId>` with a root POM on the current parent version, a
`<artifactId>-core` module with a sample class and test (JaCoCo 80% lines / 70%
branches), `config/spotbugs-exclude.xml`, the Maven wrapper, a pre-push gate hook,
and stub AGENTS/CHANGELOG/CHECKPOINT/README files. The new project passes
`./mvnw verify` as generated.
