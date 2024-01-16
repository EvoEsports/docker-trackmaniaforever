#!/bin/bash

set -e

echo "[*] Evo Esports Trackmania Forever Docker Image"

# we don't want to start the server with root permissions
if [ "$1" = './TrackmaniaServer' -a "$(id -u)" = '0' ]; then
	chown -R trackmania /server/TrackmaniaServer
	exec su-exec trackmania "$0" "$@"
fi

if [ "$TM_DEDICATED_CFG" ]; then
	DC=$TM_DEDICATED_CFG
fi

if [ "$TM_GAME_SETTINGS" ]; then
	GS=$TM_GAME_SETTINGS
fi

# we also want to have dedicated_cfg, game_settings, and noDaemon added, no matter what the user specifies
if [ "$1" = './TrackmaniaServer' ]; then
    set -- "$@" /dedicated_cfg=${DC:-dedicated_cfg.txt} /game_settings=MatchSettings/${GS:-default.txt} /nodaemon
fi

# also we need to populate the config
if [ "$1" = './TrackmaniaServer' ]; then
	if [ -z "$CONFIG_POPULATION_DISABLED" ]; then
		[ ! -f /server/GameData/Config/${DC:-dedicated_cfg.txt} ] && cp /server/GameData/Config/dedicated_cfg.default.txt /server/GameData/Config/${DC:-dedicated_cfg.txt}

		configs=()
		# required settings
		configs+=("'/dedicated/system_config/server_port' -v \"${TM_SYSTEM_SERVER_PORT:-2350}\"")
		configs+=("'/dedicated/system_config/server_p2p_port' -v \"${TM_SYSTEM_SERVER_P2P_PORT:-3450}\"")
		configs+=("'/dedicated/system_config/xmlrpc_port' -v \"${TM_SYSTEM_XMLRPC_PORT:-5000}\"")

		if [ "$TM_MASTERSERVER_LOGIN" ]; then
			configs+=("'/dedicated/masterserver_account/login' -v \"${TM_MASTERSERVER_LOGIN}\"");
		else
			echo "[!] Masterserver login not set! Use TM_MASTERSERVER_LOGIN to set it."
			exit 1
		fi

		if [ "$TM_MASTERSERVER_PASSWORD" ]; then
			TM_MASTERSERVER_PASSWORD=$(echo ${TM_MASTERSERVER_PASSWORD} | sed -e 's/\$/\\\$/g' -e 's/`/\\`/g');
			configs+=("'/dedicated/masterserver_account/password' -v \"${TM_MASTERSERVER_PASSWORD}\"");
		else
			echo "[!] Masterserver password not set! Use TM_MASTERSERVER_PASSWORD to set it."
			exit 1
		fi

		# /dedicated/authorization_levels/*
		if [ "$TM_AUTHORIZATION_SUPERADMIN_PASSWORD" ]; then configs+=("'/dedicated/authorization_levels/level[1]/password' -v \"${TM_AUTHORIZATION_SUPERADMIN_PASSWORD}\""); fi
		if [ "$TM_AUTHORIZATION_ADMIN_PASSWORD" ]; then configs+=("'/dedicated/authorization_levels/level[2]/password' -v \"${TM_AUTHORIZATION_ADMIN_PASSWORD}\""); fi
		if [ "$TM_AUTHORIZATION_USER_PASSWORD" ]; then configs+=("'/dedicated/authorization_levels/level[3]/password' -v \"${TM_AUTHORIZATION_USER_PASSWORD}\""); fi
		# /dedicated/masterserver_account/*
		#if [ "$TM_MASTERSERVER_LOGIN" ]; then configs+=("'/dedicated/masterserver_account/login' -v \"${TM_MASTERSERVER_LOGIN}\""); fi
		#if [ "$TM_MASTERSERVER_PASSWORD" ]; then configs+=("'/dedicated/masterserver_account/password' -v \"${TM_MASTERSERVER_PASSWORD}\""); fi
		if [ "$TM_MASTERSERVER_VALIDATION_KEY" ]; then configs+=("'/dedicated/masterserver_account/validation_key' -v \"${TM_MASTERSERVER_VALIDATION_KEY}\""); fi
		# /dedicated/server_options/*
		if [ "$TM_SERVER_COMMENT" ]; then configs+=("'/dedicated/server_options/login' -v \"${TM_SERVER_COMMENT}\""); fi
		if [ "$TM_SERVER_HIDE_SERVER" ]; then configs+=("'/dedicated/server_options/hide_server' -v \"${TM_SERVER_HIDE_SERVER}\""); fi
		if [ "$TM_SERVER_MAX_PLAYERS" ]; then configs+=("'/dedicated/server_options/max_players' -v \"${TM_SERVER_MAX_PLAYERS}\""); fi
		if [ "$TM_SERVER_PASSWORD" ]; then configs+=("'/dedicated/server_options/password' -v \"${TM_SERVER_PASSWORD}\""); fi
		if [ "$TM_SERVER_MAX_SPECTATORS" ]; then configs+=("'/dedicated/server_options/max_spectators' -v \"${TM_SERVER_MAX_SPECTATORS}\""); fi
		if [ "$TM_SERVER_PASSWORD_SPECTATOR" ]; then configs+=("'/dedicated/server_options/password_spectator' -v \"${TM_SERVER_PASSWORD_SPECTATOR}\""); fi
		if [ "$TM_SERVER_LADDER_MODE" ]; then configs+=("'/dedicated/server_options/ladder_mode' -v \"${TM_SERVER_LADDER_MODE}\""); fi
		if [ "$TM_SERVER_LADDER_SERVERLIMIT_MIN" ]; then configs+=("'/dedicated/server_options/ladder_serverlimit_min' -v \"${TM_SERVER_LADDER_SERVERLIMIT_MIN}\""); fi
		if [ "$TM_SERVER_LADDER_SERVERLIMIT_MAX" ]; then configs+=("'/dedicated/server_options/ladder_serverlimit_max' -v \"${TM_SERVER_LADDER_SERVERLIMIT_MAX}\""); fi
		if [ "$TM_SERVER_ENABLE_P2P_UPLOAD" ]; then configs+=("'/dedicated/server_options/enable_p2p_upload' -v \"${TM_SERVER_ENABLE_P2P_UPLOA}\""); fi
		if [ "$TM_SERVER_ENABLE_P2P_DOWNLOAD" ]; then configs+=("'/dedicated/server_options/enable_p2p_download' -v \"${TM_SERVER_ENABLE_P2P_DOWNLOAD}\""); fi
		if [ "$TM_SERVER_CALLVOTE_TIMEOUT" ]; then configs+=("'/dedicated/server_options/callvote_timeout' -v \"${TM_SERVER_CALLVOTE_TIMEOUT}\""); fi
		if [ "$TM_SERVER_CALLVOTE_RATIO" ]; then configs+=("'/dedicated/server_options/callvote_ratio' -v \"${TM_SERVER_CALLVOTE_RATIO}\""); fi
		if [ "$TM_SERVER_ALLOW_CHALLENGE_DOWNLOAD" ]; then configs+=("'/dedicated/server_options/allow_challenge_download' -v \"${TM_SERVER_ALLOW_CHALLENGE_DOWNLOAD}\""); fi
		if [ "$TM_SERVER_AUTOSAVE_REPLAYS" ]; then configs+=("'/dedicated/server_options/autosave_replays' -v \"${TM_SERVER_AUTOSAVE_REPLAYS}\""); fi
		if [ "$TM_SERVER_AUTOSAVE_VALIDATION_REPLAYS" ]; then configs+=("'/dedicated/server_options/autosave_validation_replays' -v \"${TM_SERVER_AUTOSAVE_VALIDATION_REPLAYS}\""); fi
		if [ "$TM_SERVER_REFEREE_PASSWORD" ]; then configs+=("'/dedicated/server_options/referee_password' -v \"${TM_SERVER_REFEREE_PASSWORD}\""); fi
		if [ "$TM_SERVER_REFEREE_VALIDATION_MODE" ]; then configs+=("'/dedicated/server_options/referee_validation_mode' -v \"${TM_SERVER_REFEREE_VALIDATION_MODE}\""); fi
		if [ "$TM_SERVER_USE_CHANGING_VALIDATION_SEED" ]; then configs+=("'/dedicated/server_options/use_changing_validation_seed' -v \"${TM_SERVER_USE_CHANGING_VALIDATION_SEED}\""); fi
		# /dedicated/system_config/*
		if [ "$TM_SYSTEM_CONNECTION_UPLOADRATE" ]; then configs+=("'/dedicated/system_config/connection_uploadrate' -v \"${TM_SYSTEM_CONNECTION_UPLOADRATE}\""); fi
		if [ "$TM_SYSTEM_CONNECTION_DOWNLOADRATE" ]; then configs+=("'/dedicated/system_config/connection_downloadrate' -v \"${TM_SYSTEM_CONNECTION_DOWNLOADRATE}\""); fi
		if [ "$TM_SYSTEM_FORCE_IP_ADDRESS" ]; then configs+=("'/dedicated/system_config/force_ip_address' -v \"${TM_SYSTEM_FORCE_IP_ADDRESS}\""); fi
		if [ "$TM_SYSTEM_BIND_IP_ADDRESS" ]; then configs+=("'/dedicated/system_config/bind_ip_address' -v \"${TM_SYSTEM_BIND_IP_ADDRESS}\""); fi
		if [ "$TM_SYSTEM_USE_NAT_UPNP" ]; then configs+=("'/dedicated/system_config/use_nat_upnp' -v \"${TM_SYSTEM_USE_NAT_UPNP}\""); fi
		if [ "$TM_SYSTEM_P2P_CACHE_SIZE" ]; then configs+=("'/dedicated/system_config/p2p_cache_size' -v \"${TM_SYSTEM_P2P_CACHE_SIZE}\""); fi
		if [ "$TM_SYSTEM_XMLRPC_ALLOWREMOTE" ]; then configs+=("'/dedicated/system_config/xmlrpc_allowremote' -v \"${TM_SYSTEM_XMLRPC_ALLOWREMOTE}\""); fi
		if [ "$TM_SYSTEM_BLACKLIST_URL" ]; then configs+=("'/dedicated/system_config/blacklist_url' -v \"${TM_SYSTEM_BLACKLIST_URL}\""); fi
		if [ "$TM_SYSTEM_GUESTLIST_FILENAME" ]; then configs+=("'/dedicated/system_config/guestlist_filename' -v \"${TM_SYSTEM_GUESTLIST_FILENAME}\""); fi
		if [ "$TM_SYSTEM_BLACKLIST_FILENAME" ]; then configs+=("'/dedicated/system_config/blacklist_filename' -v \"${TM_SYSTEM_BLACKLIST_FILENAME}\""); fi
		if [ "$TM_SYSTEM_PACKMASK" ]; then configs+=("'/dedicated/system_config/packmask' -v \"${TM_SYSTEM_PACKMASK}\""); fi
		if [ "$TM_SYSTEM_ALLOW_SPECTATOR_RELAYS" ]; then configs+=("'/dedicated/system_config/allow_spectator_relays' -v \"${TM_SYSTEM_ALLOW_SPECTATOR_RELAYS}\""); fi
		if [ "$TM_SYSTEM_SAVE_ALL_INDIVIDUAL_RUNS" ]; then configs+=("'/dedicated/system_config/save_all_individual_runs' -v \"${TM_SYSTEM_SAVE_ALL_INDIVIDUAL_RUNS}\""); fi
		if [ "$TM_SYSTEM_USE_PROXY" ]; then configs+=("'/dedicated/system_config/use_proxy' -v \"${TM_SYSTEM_USE_PROXY}\""); fi
		if [ "$TM_SYSTEM_PROXY_LOGIN" ]; then configs+=("'/dedicated/system_config/proxy_login' -v \"${TM_SYSTEM_PROXY_LOGIN}\""); fi
		if [ "$TM_SYSTEM_PROXY_PASSWORD" ]; then configs+=("'/dedicated/system_config/proxy_password' -v \"${TM_SYSTEM_PROXY_PASSWORD}\""); fi


		# If TM_SERVER_NAME_OVERWRITE is set, overwrite the server name on each restart of the container. If unset, only set name if empty in config file.
		if [ "$TM_SERVER_NAME_OVERWRITE" = True ]; then
			echo "[i] Server name not present in config, using \"${TM_SERVER_NAME:-Docker TrackManiaForever Server}\" as servername!"
			configs+=("'/dedicated/server_options/name' -v \"${TM_SERVER_NAME:-Docker TrackManiaForever Server}\"")
		else
			if [ -z "$(xml sel -t -v '/dedicated/server_options/name' /server/GameData/Config/${DC:-dedicated_cfg.txt})" ]; then
				echo "[i] Server name not present in config, using \"${TM_SERVER_NAME:-Docker TrackManiaForever Server}\" as servername!"
				configs+=("'/dedicated/server_options/name' -v \"${TM_SERVER_NAME:-Docker TrackManiaForever Server}\"")
			fi
		fi

		# write config parameters into config file
		for (( i = 0; i < ${#configs[@]} ; i++ )); do
			eval xml ed -L -P -u ${configs[$i]} /server/GameData/Config/${DC:-dedicated_cfg.txt}
		done

		# finally populate the MatchSettings file
		[ ! -f /server/GameData/Tracks/MatchSettings/default.txt ] && cp /server/GameData/Tracks/MatchSettings/example.txt /server/GameData/Tracks/MatchSettings/default.txt
	else
		echo "[!] Config population disabled, ignoring most environment variables passed through Docker."
	fi
fi

# fire up the prometheus exporter
if [ "$PROMETHEUS_ENABLE" = true ]; then
    echo "[i] Using Prometheus exporter."
    /usr/local/bin/trackmania_exporter &
fi

# logs hack: i have no clue why the stdout of the tm server doesn't work,
# but this links the stdout file descriptor (1) to the ConsoleLog, allowing Docker to display logs correctly
mkdir -p /server/Logs && touch /server/Logs/ConsoleLog.1.txt
ln -sf /proc/self/fd/1 /server/Logs/ConsoleLog.1.txt

# fire up the actual TM server
exec "$@"