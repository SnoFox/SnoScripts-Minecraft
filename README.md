# Sno Scripts - Minecraft

Basic Minecraft server init and maintenance scripts. Targeting vanilla servers, but works fine with Bukkit/Forge/etc

Note: This is not (yet) a watchdog. If the server crashes, it'll stay down.

# Usage
1. Throw all the shell scripts in with the server.jar
1. Configure `$HOST` and `$PASS` in `_server.sh` - this is your rcon access
1. Configure the `rcon` syntax and location
1. Optionally, Configure `$SAVE` in `backup.sh` to configure how many backups of a given label should be saved
1. Optionally, configure `$SERVER_PATH` in each shell script (if you want the scripts in a different path than the server)
1. For backups, configure the list of worlds to backup in `backup.sh`
1. Set up some crontabs - see minecraft.crontab
1. Start your server: `./init.sh start`
1. Fuggadaboutdit

# Dependencies
Expects mcrcon at $HOME/bin/mcrcon - https://github.com/Tiiffi/mcrcon
Which can be replaced or moved by setting `$RCON` in `_server.sh`
