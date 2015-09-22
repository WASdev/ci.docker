# Repository Sync – Official Liberty & ibmcom 

IBM WebSphere Application Server Liberty Profile images are available in the websphere-liberty official repository and ibmcom/websphere-liberty public repository. The scripts provided here are used to keep both the repositories in sync

## Check and Sync the repositories

1. Clone this repository.
2. Move to the directory `websphere-liberty/tools`.
3. Check and Sync repositories using:

    ```bash
    sh checkRepositorySync.sh <kernel_version| beta > <Target Repository>
    ```

## Sync the repositories

1. Clone this repository.
2. Move to the directory `websphere-liberty/tools`.
3. Sync repositories using:


    ```bash
    sh syncRepository.sh <kernel_version| beta > <Target Repository>
    ```

