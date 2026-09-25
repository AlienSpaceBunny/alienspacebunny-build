# AlienSpaceBunny shared config

This module contains shared maven config and shared build tools for AlienSpaceBunny Java projects
(rv32ima-java, emulator, alkali, kblock), plus a template for new ones.

| Path | Artifact | Purpose |
|---|---|---|
| `parent/` | `com.alienspacebunny:alienspacebunny-parent` (pom) | Java 25, plugin pins, JUnit/Mockito versions, enforcer, Spotless/Checkstyle/SpotBugs bound to `verify`, managed JaCoCo |
| `build-tools/` | `com.alienspacebunny:alienspacebunny-build-tools` (jar) | Shared `alienspacebunny/checkstyle.xml`, loaded from the Checkstyle plugin classpath |
| `template/` + `new-project.sh` | — | Skeleton for a new project on the current parent |

Only `alienspacebunny-parent` and `alienspacebunny-build-tools` are published to Maven
Central (from 0.1.1). The aggregator and template are not. Consumers resolve the parent
from Central like any other dependency; no local install is needed.

## Using the parent

```xml
<parent>
    <groupId>com.alienspacebunny</groupId>
    <artifactId>alienspacebunny-parent</artifactId>
    <version>0.1.1</version>
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

1. Edit the pin in `parent/pom.xml` (or the rules in `build-tools/`), then run `mvn install`
   and commit.
2. Release. The release plugin versions all three POMs together, including
   `parent/` and `build-tools/`, which don't inherit from the aggregator, and the
   parent's `asb.build-tools.version` property. Don't use `versions:set` for this:
   it skips them. Either
   - run the **Release** GitHub workflow (Actions → Release → Run workflow). It
     verifies, tags `v<version>`, pushes, and uploads to Central, or
   - release locally without publishing:
     ```bash
     mvn release:prepare release:perform   # tags v0.1.1, installs 0.1.1, moves to 0.1.2-SNAPSHOT
     git push && git push origin v0.1.1    # when you choose to
     ```
   Consumers depend on release versions only, never `-SNAPSHOT`.
3. In each consumer, then run `./mvnw spotless:apply verify`:
   ```bash
   ./mvnw versions:update-parent -DparentVersion=0.1.1 -DgenerateBackupPoms=false
   ```
   A formatter bump usually changes source layout. Commit that reformat together
   with the parent bump.

## Maven Central

`-Pcentral-release deploy` (the workflow's last step) builds sources and javadoc
jars, signs everything with GPG, and uploads one bundle through the Central Portal
(`central-publishing-maven-plugin`). With **autoPublish** unchecked (the default),
the deployment is only validated. Nothing becomes public until you click
**Publish** in the Portal, and you can **Drop** it there instead. Central releases
can never be changed or deleted once published.

The `central-release` profile lives in `parent/pom.xml` too, so a consumer such as
rv32ima-java can publish locally with `mvn -Pcentral-release deploy`. It must
declare its own `<url>` and `<scm>`, and its jar modules must attach javadoc.

One-time setup (the `com.alienspacebunny` namespace is already verified):

1. **Portal token:** central.sonatype.com → Account → Generate User Token. Store
   it as repository secrets `CENTRAL_USERNAME` and `CENTRAL_PASSWORD`.
2. **Signing key:** create one (`gpg --quick-gen-key "AlienSpaceBunny Releases <email>" rsa4096 sign 3y`),
   publish the public key (`gpg --keyserver keys.openpgp.org --send-keys <KEYID>`,
   then confirm the address by email; `keyserver.ubuntu.com` also works), and store
   `gpg --armor --export-secret-keys <KEYID>` and its passphrase as secrets
   `GPG_PRIVATE_KEY` and `GPG_PASSPHRASE`.
3. **Recovery:** if the upload fails after the tag was pushed, run the workflow again
   with **existingTag** set (e.g. `v0.1.1`). It skips `release:prepare` and republishes that tag.
4. **Push access:** the workflow pushes the release commits and tag to `main` with
   the job's `GITHUB_TOKEN`. If `main` is protected, allow GitHub Actions to bypass.

Local check without uploading (no credentials needed; it fails only at the upload
step and leaves the bundle for inspection). Run it on a release-versioned copy:
the plugin treats `-SNAPSHOT` differently.

```bash
mvn -s <settings with a dummy "central" server> -Pcentral-release deploy \
    -Dgpg.skip -Dmaven.install.skip -DcentralBaseUrl=http://127.0.0.1:9
unzip -l build-tools/target/central-publishing/central-bundle.zip
```

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
