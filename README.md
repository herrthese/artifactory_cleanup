
# Cleanup Artifactory with ruby
the following tool will cleanup you artifactury repos.

# RUN
    john@doe:/artifactory_cleanup $ ruby cleanup.rb

# CONFIG
use the `./data/artifactury_cleanup.yaml` for the configuration.

    ---
    days1:
      14:
        - yum-testrepo1-local
        - yum-testrepo2-local
    days2:
      30:
        - yum-testrepo3-local
        - maven-testrepo4-local
        - maven-testrepo5-local
    days3:
      60:
        - yum-testrepo6-local
        - maven-testrepo7-local
        - maven-testrepo8-local

Example: days1 will be deleted when the artifacts are olden than 14 days.        
