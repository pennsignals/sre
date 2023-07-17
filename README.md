# ServerAdminScripts

Repository for all scripts hosted on the fileshare used to administer servers.

Local Run Instructions

1. scp the acs key out of fileshare and into the .ssh folder for each environment (cloud staging, production, on premise).
2. scp the secrets.env file out of the fileshare and into the .ssh folder for each environment.
3. For on.premise.production cat out the id_rsa file on the fileshare, copy the contents and touch a new id_rsa file in .ssh. Copy in the contents to the new id_rsa locally.
4. chmod 600 the new id_rsa file and any other acs_key files that you may have had to create.
5. Ensure you are on the VPN when you attempt to run any sre scripts from local.
