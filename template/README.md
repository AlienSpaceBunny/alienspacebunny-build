# __NAME__

```bash
./mvnw verify          # tests, coverage, formatting, Checkstyle, SpotBugs
./mvnw spotless:apply  # format
```

Requires JDK 25 and `com.alienspacebunny:alienspacebunny-parent` in the local
Maven repository (`mvn install` in `../alienspacebunny-build`).
