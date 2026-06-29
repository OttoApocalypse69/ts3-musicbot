package ts3musicbot.util

data class CommandList(
    var commandPrefix: String = "!",
    // list of available commands. First is the name of the command, second is the default value.
    var commandList: MutableMap<String, String> =
        mapOf(
            Pair("help", "!help"),
            Pair("play", "!play"),
            Pair("queue-add", "!queue-add"),
            Pair("queue-playnext", "!queue-playnext"),
            Pair("queue-playnow", "!queue-playnow"),
            Pair("queue-play", "!queue-play"),
            Pair("queue-list", "!queue-list"),
            Pair("queue-list-short", "!queue"),
            Pair("queue-delete", "!queue-delete"),
            Pair("queue-clear", "!queue-clear"),
            Pair("queue-shuffle", "!queue-shuffle"),
            Pair("shuffle", "!shuffle"),
            Pair("queue-skip", "!skip"),
            Pair("queue-move", "!queue-move"),
            Pair("queue-stop", "!stop"),
            Pair("queue-status", "!queue-status"),
            Pair("queue-nowplaying", "!queue-nowplaying"),
            Pair("nowplaying", "!nowplaying"),
            Pair("queue-pause", "!pause"),
            Pair("queue-resume", "!resume"),
            Pair("queue-repeat", "!queue-repeat"),
            Pair("info", "!info"),
            Pair("search", "!search"),
            Pair("volume", "!volume"),
            Pair("volume-short", "!vol"),
            Pair("volumeup", "!volumeup"),
            Pair("volume-up-short", "!volup"),
            Pair("volumedown", "!volumedown"),
            Pair("volume-down-short", "!voldown"),
            Pair("mute", "!mute"),
            Pair("loop", "!loop"),
            Pair("loopqueue", "!loopqueue"),
            Pair("loopoff", "!loopoff"),
            Pair("loopstatus", "!loopstatus"),
            Pair("goto", "!goto"),
            Pair("return", "!return"),
        ).toMutableMap(),
) {
    var helpMessages = createHelpMessages()

    @Suppress("ktlint:standard:max-line-length")
    private fun createHelpMessages(): Map<String?, String> =
        mapOf(
            Pair(
                "help",
                "\n" +
                    "General commands:\n" +
                    "${commandList["help"]} <command>                              -Shows this help message. Use ${commandList["help"]} <command> to get more help on a specific command.\n" +
                    "${commandList["play"]} <query/link>                           -Search for a song and start playing it immediately.\n" +
                    "${commandList["queue-add"]}                                   -Add track(s) to queue by link or directly searching and adding the first match to the queue.\n" +
                    "${commandList["queue-playnext"]}                              -Add track/playlist/album etc. to the top of the queue. Add multiple links separated by a comma \",\". Shuffle with the -s option\n" +
                    "${commandList["queue-playnow"]}                               -Add track/playlist/album etc. to the top of the queue and start playing it immediately.\n" +
                    "${commandList["queue-play"]}                                  -Play the song queue\n" +
                    "${commandList["queue-list"]} <--all,--limit>                  -Lists current songs in queue. Add the -a/--all option to show all tracks or -l/--limit to set a limit to the amount of tracks.\n" +
                    "${commandList["queue-delete"]} <link(s)/position(s)>          -Delete song(s) from the queue. If you want to delete multiple tracks, just separate them with a comma \",\". Optionally you can just use a position to delete a track.\n" +
                    "${commandList["queue-clear"]}                                 -Clears the song queue\n" +
                    "${commandList["shuffle"]}                                     -Shuffles the queue\n" +
                    "${commandList["queue-skip"]}                                  -Skips the currently playing song instantly.\n" +
                    "${commandList["queue-move"]} <link> -p <pos>                  -Moves a track to a desired position in the queue. <link> should be your song link and <pos> should be the new position of your song.\n" +
                    "${commandList["queue-stop"]}                                  -Stops the queue\n" +
                    "${commandList["queue-status"]}                                -Returns the status of the song queue\n" +
                    "${commandList["nowplaying"]}                                  -Returns information on the currently playing track\n" +
                    "${commandList["queue-pause"]}                                 -Pauses playback\n" +
                    "${commandList["queue-resume"]}                                -Resumes playback\n" +
                    "${commandList["queue-repeat"]} <amount>                       -Adds the currently playing song to the top of the queue. <amount> is how many times the song should be queued.\n" +
                    "${commandList["loop"]}                                        -Toggles looping of the current track on/off\n" +
                    "${commandList["loopqueue"]}                                   -Toggles looping of the entire queue on/off\n" +
                    "${commandList["loopoff"]}                                     -Turns off all looping\n" +
                    "${commandList["loopstatus"]}                                  -Shows current loop mode\n" +
                    "${commandList["search"]} <service> <type> <text> <limit>      -Search on music services. Shows 10 first results by default. <type> can be track, video, playlist or channel. You can set the amount of results with the -l/--limit flag.\n" +
                    "${commandList["info"]} <link/search query>                    -Shows info on the given search query or link(s). <link> can be one or more links, separated by a comma.\n" +
                    "${commandList["volume"]} <0-150>                              -Get or set playback volume (0-150%).\n" +
                    "${commandList["volumeup"]}                                    -Increase volume by 10%\n" +
                    "${commandList["volumedown"]}                                  -Decrease volume by 10%\n" +
                    "${commandList["mute"]}                                        -Mute/unmute playback\n" +
                    "${commandList["goto"]} <channelpath> -p <channelpassword>     -Move the bot to a different channel.\n" +
                    "${commandList["return"]}                                      -Return the bot back to the original channel.\n",
            ),
            Pair(
                "queue-add",
                "\n" +
                    "Showing help for ${commandList["queue-add"]} command:\n" +
                    "${commandList["queue-add"]} lets you add songs, albums and playlists to the end of the song queue.\n" +
                    "You can also pass in a link to an artist, which will result in the artist's top tracks getting added to the queue.\n" +
                    "Instead of using links, you can search like with the ${commandList["search"]} command,\n" +
                    "but the first search result will be automatically added to the queue. For more information on how to search,\n" +
                    "see ${commandList["help"]} ${commandList["search"]}\n" +
                    "Counting starts from 0, so the first song is at position 0, second is at 1 and so on.\n" +
                    "You can add options either before or after song link(s).\n" +
                    "Available options:\n" +
                    "-s    \t-Shuffle the playlist/album etc. before adding to the queue.\n" +
                    "-p    \t-Add track(s) to a specific position in the queue.\n" +
                    "-r    \t-Reverse playlist/album etc. before adding to the queue.\n" +
                    "-l    \t-Limit the amount of tracks to add from the given list(s).\n" +
                    "Example - Add playlist to queue at position 15 and shuffle it before that:\n" +
                    "${commandList["queue-add"]} -s https://bandcamp.com/album/example -p 15\n" +
                    "Example - Search for an album and add it to the queue:\n" +
                    "${commandList["queue-add"]} bandcamp album Haken Affinity\n" +
                    "Example - Search for a track and add it to the queue:\n" +
                    "${commandList["queue-add"]} bandcamp track Haken Initiate",
            ),
            Pair(
                "queue-playnext",
                "\n" +
                    "Showing help for ${commandList["queue-playnext"]} command:\n" +
                    "${commandList["queue-playnext"]} lets you add songs, albums and playlists to the start of the song queue.\n" +
                    "You can also pass in a link to an artist, which will result in the artist's top tracks getting added to the queue.\n" +
                    "Instead of using links, you can search like with the ${commandList["search"]} command,\n" +
                    "but the first search result will be automatically added to the queue.\n" +
                    "Counting starts from 0, so the first song is at position 0, second is at 1 and so on.\n" +
                    "You can add options either before or after song link(s).\n" +
                    "Available options:\n" +
                    "-s    \t-Shuffle the playlist/album before adding to the queue.\n" +
                    "-p    \t-Add track(s) to a specific position in the queue.\n" +
                    "-r    \t-Reverse playlist/album etc. before adding to the queue.\n" +
                    "-l    \t-Limit the amount of tracks to add from the given list(s).\n" +
                    "Example - Add playlist to queue at position 15 and shuffle it before that:\n" +
                    "${commandList["queue-playnext"]} -s https://bandcamp.com/album/example -p 15\n" +
                    "Example - Search for an album and add it to the queue:\n" +
                    "${commandList["queue-playnext"]} bandcamp album Haken Affinity\n" +
                    "Example - Search for a track and add it to the queue:\n" +
                    "${commandList["queue-playnext"]} bandcamp track Haken Initiate",
            ),
            Pair(
                "queue-playnow",
                "\n" +
                    "Showing help for ${commandList["queue-playnow"]} command:\n" +
                    "${commandList["queue-playnow"]} can be used if you want to add songs to the top of the queue, and start playing them immediately.\n" +
                    "Example - Search for the track \"Pink Floyd - Time\", add the first result to the queue and then start playing it:\n" +
                    "${commandList["queue-playnow"]} track pink floyd time",
            ),
            Pair(
                "queue-play",
                "\n" +
                    "Showing help for ${commandList["queue-play"]} command:\n" +
                    "${commandList["queue-play"]} starts playing songs in the song queue.",
            ),
            Pair(
                "queue-list",
                "\n" +
                    "Showing help for ${commandList["queue-list"]} command:\n" +
                    "${commandList["queue-list"]} shows a list of songs in the queue.\n" +
                    "By default it shows the first 15 songs in the queue.\n" +
                    "Available options:\n" +
                    "-a, --all    \t-Show all songs in the queue\n" +
                    "-l, --limit <amount> -Limit amount of songs to return.\n" +
                    "Example - run ${commandList["queue-list"]} with a limit of 30 songs:\n" +
                    "${commandList["queue-list"]} --limit 30",
            ),
            Pair(
                "play",
                "\n" +
                    "Showing help for ${commandList["play"]} command:\n" +
                    "${commandList["play"]} searches online music services and starts playback immediately.\n" +
                    "You can also pass a direct music link.\n" +
                    "Example - Search and play a song:\n" +
                    "${commandList["play"]} never gonna give you up\n" +
                    "Example - Play a direct link:\n" +
                    "${commandList["play"]} https://bandcamp.com/track/example",
            ),
            Pair(
                "queue-delete",
                "\n" +
                    "Showing help for ${commandList["queue-delete"]} command:\n" +
                    "${commandList["queue-delete"]} lets you delete a track, or tracks from the queue.\n" +
                    "If the same track is in the queue multiple times,\n" +
                    "the bot will ask you to choose which one you want to delete.\n" +
                    "Available options:\n" +
                    "-a, --all    \t-Delete all matching tracks from the queue.\n" +
                    "-f, --first    \t-Delete the first matching track(s) from the queue.\n" +
                    "-A, --all-artist-tracks    -Delete all tracks where the given artist appears.\n" +
                    "Example - Delete a track from the queue using a link:\n" +
                    "${commandList["queue-delete"]} https://bandcamp.com/track/example\n" +
                    "Example - Delete multiple tracks using links:\n" +
                    "${commandList["queue-delete"]} https://bandcamp.com/track/example, https://bandcamp.com/track/example2\n" +
                    "Example - Delete a track from the queue at position 86:\n" +
                    "${commandList["queue-delete"]} 86\n" +
                    "Example - Delete all tracks matching the given link:\n" +
                    "${commandList["queue-delete"]} --all https://bandcamp.com/track/example",
            ),
            Pair(
                "queue-clear",
                "\n" +
                    "Showing help for ${commandList["queue-clear"]} command:\n" +
                    "By default, ${commandList["queue-clear"]} command clears the song queue.\n" +
                    "Available arguments:\n" +
                    "--cache    \t\tClear only the track cache.\n" +
                    "--all      \t\tClear both the song queue and track cache.\n" +
                    "Example - Clear the song queue:\n" +
                    "${commandList["queue-clear"]}\n" +
                    "Example - Clear only the track cache:\n" +
                    "${commandList["queue-clear"]} --cache",
            ),
            Pair(
                "queue-shuffle",
                "\n" +
                    "Showing help for ${commandList["queue-shuffle"]} command:\n" +
                    "${commandList["queue-shuffle"]} shuffles the song queue.\n" +
                    "You can also use ${commandList["shuffle"]} as a shortcut.",
            ),
            Pair(
                "shuffle",
                "\n" +
                    "Showing help for ${commandList["shuffle"]} command:\n" +
                    "${commandList["shuffle"]} shuffles the song queue. Same as ${commandList["queue-shuffle"]}.",
            ),
            Pair(
                "queue-skip",
                "\n" +
                    "Showing help for ${commandList["queue-skip"]} command:\n" +
                    "${commandList["queue-skip"]} skips the currently playing song instantly.",
            ),
            Pair(
                "queue-move",
                "\n" +
                    "Showing help for ${commandList["queue-move"]} command:\n" +
                    "${commandList["queue-move"]} lets you move a song or songs to a new position in the queue.\n" +
                    "If the same track is in the queue multiple times,\n" +
                    "the bot will ask you to choose which one you want to delete\n" +
                    "unless specified otherwise.\n" +
                    "If you don't specify a position using -p or --position, 0 will be used by default.\n" +
                    "Available arguments:\n" +
                    "-p, --position <pos>    \tSet a position where to move the song.\n" +
                    "-a, --all             \t\tMove all matching songs to the new position.\n" +
                    "-f, --first           \t\tMove the first matching song to the new position.\n" +
                    "Example - Move all matching songs to position 10:\n" +
                    "${commandList["queue-move"]} -a https://bandcamp.com/track/example -p 10\n" +
                    "Example - Move a song from position 5 to position 0:\n" +
                    "${commandList["queue-move"]} 5 -p 0\n" +
                    "Example - Move first matching song to position 10:\n" +
                    "${commandList["queue-move"]} -f https://bandcamp.com/track/example -p 10",
            ),
            Pair(
                "queue-stop",
                "\n" +
                    "Showing help for ${commandList["queue-stop"]} command:\n" +
                    "${commandList["queue-stop"]} stops the song queue.",
            ),
            Pair(
                "queue-status",
                "\n" +
                    "Showing help for ${commandList["queue-status"]} command:\n" +
                    "${commandList["queue-status"]} returns the status of the queue.\n" +
                    "The status can be either \"Active\" or \"Not active\"",
            ),
            Pair(
                "queue-nowplaying",
                "\n" +
                    "Showing help for ${commandList["queue-nowplaying"]} command:\n" +
                    "${commandList["queue-nowplaying"]} returns information on the currently playing song.\n" +
                    "You can also use ${commandList["nowplaying"]} as a shortcut.",
            ),
            Pair(
                "nowplaying",
                "\n" +
                    "Showing help for ${commandList["nowplaying"]} command:\n" +
                    "${commandList["nowplaying"]} returns information on the currently playing song. Same as ${commandList["queue-nowplaying"]}.",
            ),
            Pair(
                "queue-pause",
                "\n" +
                    "Showing help for ${commandList["queue-pause"]} command:\n" +
                    "${commandList["queue-pause"]} pauses the song queue.",
            ),
            Pair(
                "queue-resume",
                "\n" +
                    "Showing help for ${commandList["queue-resume"]} command:\n" +
                    "${commandList["queue-resume"]} resumes playback if the song queue is paused.",
            ),
            Pair(
                "queue-repeat",
                "\n" +
                    "Showing help for ${commandList["queue-repeat"]} command:\n" +
                    "${commandList["queue-repeat"]} Adds the currently playing song back to the top of the queue.\n" +
                    "Available arguments:\n" +
                    "-a, --amount <amount>    \tSet how many times the currently playing song should be added to the queue.\n" +
                    "Example - Repeat the currently playing track once:\n" +
                    "${commandList["queue-repeat"]}\n" +
                    "Example - Repeat the currently playing track 5 times:\n" +
                    "${commandList["queue-repeat"]} -a 5",
            ),
            Pair(
                "loop",
                "\n" +
                    "Showing help for ${commandList["loop"]} command:\n" +
                    "${commandList["loop"]} toggles looping of the current track.\n" +
                    "When enabled, the currently playing song will restart automatically when it ends.\n" +
                    "Use ${commandList["loopoff"]} to disable or ${commandList["loopstatus"]} to check.",
            ),
            Pair(
                "loopqueue",
                "\n" +
                    "Showing help for ${commandList["loopqueue"]} command:\n" +
                    "${commandList["loopqueue"]} toggles looping of the entire queue.\n" +
                    "When enabled, songs are re-added to the end of the queue after playing.",
            ),
            Pair(
                "loopoff",
                "\n" +
                    "Showing help for ${commandList["loopoff"]} command:\n" +
                    "${commandList["loopoff"]} disables all looping (track and queue).",
            ),
            Pair(
                "loopstatus",
                "\n" +
                    "Showing help for ${commandList["loopstatus"]} command:\n" +
                    "${commandList["loopstatus"]} shows the current loop mode (off, track, or queue).",
            ),
            Pair(
                "volume",
                "\n" +
                    "Showing help for ${commandList["volume"]} command:\n" +
                    "${commandList["volume"]} gets or sets the playback volume.\n" +
                    "Volume range is 0 to 150 (percent).\n" +
                    "Use without a value to see the current volume.\n" +
                    "Aliases: ${commandList["volume-short"]}\n" +
                    "Example - Set volume to 80%:\n" +
                    "${commandList["volume"]} 80\n" +
                    "Example - Check current volume:\n" +
                    "${commandList["volume"]}",
            ),
            Pair(
                "volumeup",
                "\n" +
                    "Showing help for ${commandList["volumeup"]} command:\n" +
                    "${commandList["volumeup"]} increases the volume by 10%.\n" +
                    "Alias: ${commandList["volume-up-short"]}",
            ),
            Pair(
                "volumedown",
                "\n" +
                    "Showing help for ${commandList["volumedown"]} command:\n" +
                    "${commandList["volumedown"]} decreases the volume by 10%.\n" +
                    "Alias: ${commandList["volume-down-short"]}",
            ),
            Pair(
                "mute",
                "\n" +
                    "Showing help for ${commandList["mute"]} command:\n" +
                    "${commandList["mute"]} toggles mute. If volume is above 0, it mutes. If already muted, it unmutes to 50%.",
            ),
            Pair(
                "info",
                "\n" +
                    "Showing help for ${commandList["info"]} command:\n" +
                    "${commandList["info"]} shows information on a given search query or link(s).\n" +
                    "You can either use 1 or more links,\n" +
                    "or search for something using the same syntax as with the ${commandList["search"]} command.\n" +
                    "Example - Get info on a track link:\n" +
                    "${commandList["info"]} https://bandcamp.com/track/example\n" +
                    "Example 2 - Show info on the artist \"The Algorithm\":\n" +
                    "${commandList["info"]} bc artist the algorithm",
            ),
            Pair(
                "search",
                "\n" +
                    "Showing help for ${commandList["search"]} command:\n" +
                    "${commandList["search"]} can be used to search for tracks, playlists and albums on supported music services.\n" +
                    "When searching, you first need to specify which service you want to search on.\n" +
                    "Available services:\n" +
                    "bc, bandcamp   \t\tDo a Bandcamp search.\n" +
                    "sl, songlink   \t\tDo a SongLink search.\n" +
                    "am, applemusic   \t\tDo an Apple Music search.\n" +
                    "After that, specify what type of search you are doing.\n" +
                    "Available search types:\n" +
                    "track    \t\tSearch for a track.\n" +
                    "album   \t\tSearch for an album.\n" +
                    "artist   \t\tSearch for an artist.\n" +
                    "podcast  \t\tSearch for a podcast.\n" +
                    "Available options:\n" +
                    "-l, --limit    \tSet amount of search results to show.\n" +
                    "Example - Search on Bandcamp for a track with the name \"Haken - Initiate\":\n" +
                    "${commandList["search"]} bc track Haken Initiate\n" +
                    "Example 2 - Search on Bandcamp for an album with the name \"Affinity\" and set a limit to show 5 search results:\n" +
                    "${commandList["search"]} bc album Affinity --limit 5",
            ),
            Pair(
                "goto",
                "\n" +
                    "Showing help for ${commandList["goto"]} command:\n" +
                    "${commandList["goto"]} can be used to move the bot to another channel.\n" +
                    "Example - Move to a channel at \"Music/MusicBot\":\n" +
                    "${commandList["goto"]} Music/MusicBot\n" +
                    "Example 2 - Move to a channel at \"Music/MusicBot\" with the password \"123\":\n" +
                    "${commandList["goto"]} Music/MusicBot -p 123\n" +
                    "Example 3 - Move to a channel at \"Music/Music Bot\" with the password \"secret password\"\n" +
                    "${commandList["goto"]} \"Music/Music Bot\" -p \"secret password\"",
            ),
            Pair(
                "return",
                "\n" +
                    "Showing help for ${commandList["return"]} command:\n" +
                    "${commandList["return"]} can be used to return the bot to the original channel.",
            ),
        )

    fun applyCustomCommands(
        customPrefix: String,
        customCommands: Map<String, String>,
    ) {
        // remove existing command prefixes from commands
        commandList.forEach {
            if ((commandList[it.key] ?: return@forEach).startsWith(commandPrefix)) {
                commandList[it.key] = it.value.substringAfter(commandPrefix)
            }
        }
        // update commandList with custom commands and apply the custom prefix too.
        commandPrefix = customPrefix
        customCommands.forEach {
            commandList[it.key] = commandPrefix + it.value
        }
        commandList.filterNot { customCommands.keys.contains(it.key) }.forEach {
            commandList[it.key] = commandPrefix + it.value
        }
        // create new help messages with the new command list
        helpMessages = createHelpMessages()
    }
}
