This project uses sqlite-jdbc 3.43.1.0 (no SLF4J - one JAR only).

If you see "NoClassDefFoundError: org/slf4j/LoggerFactory", you have 3.45+ which needs SLF4J.
Fix: Use 3.43.1.0 instead.

  Option 1: Double-click DOWNLOAD_SQLITE.bat (in the parent folder). It downloads sqlite-jdbc-3.43.1.0.jar here.

  Option 2: Download and save as sqlite-jdbc-3.43.1.0.jar in this folder:
  https://repo1.maven.org/maven2/org/xerial/sqlite-jdbc/3.43.1.0/sqlite-jdbc-3.43.1.0.jar

Then in IntelliJ: File -> Invalidate Caches -> Invalidate and Restart. Rebuild and run.
