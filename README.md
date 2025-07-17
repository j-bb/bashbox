# bashbox
A set of bash tools and helping scripts.

## Helping scripts
The goal is to keep here some scripts used daily, to launch it quickly and efficiently. \
Also, one goal is to automate some configuration I had to do on every new installation. \
For example, a list of package and application to install as part of my default kit. \

This is all based on a very personal use. \

For each distribution, it is possible to create a sub-folder with scripts. \

To use a script : ./bashbox.sh <command> where command is a script in the distribution folder. \

## bash tools
A common folder is to come (currently only on dev on my machine). \
This will contain at least a fwk.sh file with bash fonction taken from the time I automated a full Devops C/CD on cloud with bash, back in 2005. \
- ask for a password
- ask for an information
- log properly (imbricated to help debug, color, etc)
- replace variable in files to have templates
- sign files,
- install from various format with all the check (MD5, etc) that we are all suppose to do but ... so it will be automated.
- manage cron tab to allow CRUD on tasks.


## todo
### install script
- Re-entrant.
- Add bashbox folder to the $PATH.
- Add a link (ln -s) to the /$HOME/bashbox
- Manage bashbox updates with git (git pull)
### common folder
Just setup this fwk.sh file from the pioneer age of Devops.
### harden OS
This will be based on the same pioneer age of cloud where I hardened the bare metal Linux server provided in a data-center.\
- ARP firewall to prevent local attack.
- TCP firewall (amazingly not activated neither configured by default on Linux)
- Linux kernel configuration to harden the TCP stack and other elements to improve security.
### desktop backup all scripted
Currently, I'm testing cronopete and it works fine. \
If the pending test is positive, just script the installation and configuration.
### baskbox Devops
Think to a dev branch in Github + some automated check when pushing, just for fun as the size of the project doesn't require such rigorous process.
