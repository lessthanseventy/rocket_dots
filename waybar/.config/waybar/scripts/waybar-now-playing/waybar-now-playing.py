#!/usr/bin/env python3

# author: Lucas Alber

# Dependencies: playerctl, Glib, Gio

# Config:
# "custom/media": {
#         "format": "{icon} {}",
#         "escape": true,
#         "return-type": "json",
#         "max-length": 40,
#         "on-click": "playerctl play-pause",
#         "on-click-right": "playerctld shift",
#         "smooth-scrolling-threshold": 1,
#         "on-scroll-up": "playerctl next",
#         "on-scroll-down": "playerctl previous",
#         "format-icons": {
#           "spotify": "",
#           "firefox": "",
#           "chromium": "",
#           "kdeconnect": "",
#           "default": ""
#         },
#         "exec": " $HOME/.config/waybar/scripts/waybar-now-playing/waybar-now-playing.py 2> /dev/null",
#         "exec-on-event": false
#     },

import json
import shutil
import signal
import subprocess
from typing import Dict, List, Optional, Set

import gi

gi.require_version("Playerctl", "2.0")

from gi.repository import Gio, GLib, Playerctl  # noqa: E402

MPRIS_PREFIX = "org.mpris.MediaPlayer2."
DBUS_PATH = "/org/freedesktop/DBus"
DBUS_INTERFACE = "org.freedesktop.DBus"
MPRIS_PATH = "/org/mpris/MediaPlayer2"
PLAYERCTLD_BUS_NAME = "org.mpris.MediaPlayer2.playerctld"
PLAYERCTLD_INTERFACE = "com.github.altdesktop.playerctld"
PLAYERCTLD_PLAYER_NAMES_PROP = "PlayerNames"
SHUTDOWN_SIGNALS = [signal.SIGINT, signal.SIGTERM]
PLAYBACK_STATUS_ICON = {
    # No player is active
    None: "",
    Playerctl.PlaybackStatus.STOPPED: "",
    Playerctl.PlaybackStatus.PLAYING: "",
    Playerctl.PlaybackStatus.PAUSED: "\uf28b ",
}
METADATA_FROM_PLAYER = [
    lambda player: player.get_artist(),
    lambda player: player.get_title(),
]
METADATA_SEP = " - "

manager = Playerctl.PlayerManager()
# Instance to player
current_players: Dict[str, Playerctl.Player] = {}
current_player: Optional[Playerctl.Player] = None
# As received from playerctld "playername.instance" e.g. chromium.instance4978
current_player_instance: Optional[str] = None
# A player name that has appeared but a player was not yet created.
# Make sure a player is not created if in our 1s timeout (see
# on_name_appeared) the player has already vanished.
pending_players: Set[str] = set()
# Must be kept global to prevent garbage collection
playerctld_proxy = None


def get_metadata_str():
    if current_player is None:
        return "No active player"
    md = []
    for func in METADATA_FROM_PLAYER:
        if s := func(current_player):
            md.append(s)
    metadata_str = METADATA_SEP.join(md)
    if not metadata_str:
        return "No metadata available"
    return metadata_str


def print_state():
    if current_player is None:
        icon = PLAYBACK_STATUS_ICON[None]
        player_name = "noplayer"
    else:
        playback_status = current_player.get_property("playback-status")
        icon = PLAYBACK_STATUS_ICON[playback_status]
        # Eg chromium for chromium.instance4978
        player_name = current_player.get_property("player-name")
    metadata_str = get_metadata_str()
    data = {
        "text": f"{icon}{metadata_str}",
        "tooltip": metadata_str,
        "class": f"custom-{player_name}",
        "alt": player_name,
    }
    print(json.dumps(data), flush=True)


def signal_handler(sig, frame, loop):
    if sig in SHUTDOWN_SIGNALS and loop:
        loop.quit()


def start_playerctld():
    playerctld = shutil.which("playerctld")
    if not playerctld:
        print("playerctld is not available")
        exit(1)
    subprocess.check_call(
        ["playerctld", "daemon"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )


def on_playback_status(
    player: Playerctl.Player, status, manager: Playerctl.PlayerManager
):
    if player == current_player:
        print_state()


def on_metadata(player: Playerctl.Player, metadata, manager: Playerctl.PlayerManager):
    if player == current_player:
        print_state()


def on_name_appeared(
    manager: Playerctl.PlayerManager, player_name: Playerctl.PlayerName
):
    def add_player():
        global current_player, pending_players
        if player_name.name not in pending_players:
            return
        else:
            pending_players.remove(player_name.name)
        player = Playerctl.Player.new_from_name(player_name)
        player.connect("playback-status", on_playback_status, manager)
        player.connect("metadata", on_metadata, manager)
        current_players[player_name.instance] = player
        if player_name.instance == current_player_instance:
            current_player = player
        print_state()
        # timeout_add would call this periodically if this is True.
        return False

    pending_players.add(player_name.name)
    # For some reason if we add the player to fast
    # metadata is not working on the first title.
    GLib.timeout_add(1000, add_player)


def on_name_vanished(
    manager: Playerctl.PlayerManager, player_name: Playerctl.PlayerName
):
    global current_player, current_player_instance, pending_players
    if player_name.name in pending_players:
        pending_players.remove(player_name.name)
    if player_name.instance in current_players:
        del current_players[player_name.instance]
    if current_player_instance == player_name.instance:
        current_player = None


def on_playerctld_playernames(names: List[str]):
    global current_player_instance, current_player
    if names:
        current_player_instance = names[0][len(MPRIS_PREFIX) :]
        current_player = current_players.get(current_player_instance, None)
    else:
        current_player_instance = None
    print_state()


def on_playerctld_property_change(
    playerctld_proxy, changed_properties, invalidated_properties
):
    if changed_properties.lookup_value(PLAYERCTLD_PLAYER_NAMES_PROP) is None:
        return
    playernames = changed_properties[PLAYERCTLD_PLAYER_NAMES_PROP]
    on_playerctld_playernames(playernames)


def connect_playerctld():
    global bus_proxy, playerctld_proxy
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    bus_proxy = Gio.DBusProxy.new_sync(
        bus,
        Gio.DBusProxyFlags.NONE,
        None,
        DBUS_INTERFACE,
        DBUS_PATH,
        DBUS_INTERFACE,
        None,
    )
    res = bus_proxy.call_sync(
        "ListNames", None, Gio.DBusCallFlags.NO_AUTO_START, 500, None
    )
    if PLAYERCTLD_BUS_NAME not in res[0]:
        print("Could not find playerctld on DBus")
        exit(1)
    playerctld_proxy = Gio.DBusProxy.new_sync(
        bus,
        Gio.DBusProxyFlags.NONE,
        None,
        PLAYERCTLD_BUS_NAME,
        MPRIS_PATH,
        PLAYERCTLD_INTERFACE,
        None,
    )
    playerctld_proxy.connect("g-properties-changed", on_playerctld_property_change)
    playernames = playerctld_proxy.get_cached_property(PLAYERCTLD_PLAYER_NAMES_PROP)
    on_playerctld_playernames(playernames)


def main():
    start_playerctld()

    loop = GLib.MainLoop()
    for sig in SHUTDOWN_SIGNALS:
        signal.signal(sig, lambda sig, frame: signal_handler(sig, frame, loop))

    connect_playerctld()

    # Keep track of all active players
    manager.connect("name-appeared", on_name_appeared)
    manager.connect("name-vanished", on_name_vanished)
    for name in manager.props.player_names:
        on_name_appeared(manager, name)

    print_state()

    loop.run()


if __name__ == "__main__":
    main()
