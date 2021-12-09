# Trustworthy Modules

Hello! This is the Project 2 repository for group 21 in ECE461 in Fall 2021. 


# Files and Folders
/server/: Contains the RESTful API
> Source/App: Contains the server code to implement route handling.
> Source/Run: Contains the executable to host the server.
> Tests: Contains the unit tests that check the implemented routes.

/scoring/: Contains scripts related to scoring functions and test code.
>install.py: Installs dependencies based on depend.txt.
>perform.py: Contains functions implementing scoring functions.
>test.py: Unit-test module to test perform.py.

/authenticate/ : Contains authentication scripts and test code.
>authenticate.py: Contains functions related to registration and deletion of admins and users.
>authenticate_test.py: Unit-test module to test authenticate.py.

/frontend/: Contains front-end contents implementing Django.

/ingest/: Contains ingestion scripts and test code.
>ingest.py: Contains functions relation to ingestion and management of local and remote repositories.
>ingest_test.py: Unit-test module to test ingest.py
>packages/: Contains ingested package zip files
