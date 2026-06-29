# TS3 Music Bot Docker Guide

This guide explains how to run the TeamSpeak 3 music bot with Docker from a clean machine. It covers setup, commands, troubleshooting, and the exact configuration used for the current bot.

The Docker setup runs the official TeamSpeak 3 client headlessly, joins your server/channel, listens to channel chat, and plays music through the bot's microphone input. The default command prefix is `!`, so users type commands like `!play never gonna give you up` in TeamSpeak channel chat.

Spotify is disabled by default. You do not need Spotify Premium or API keys for normal `!play` usage.

## What The Container Runs

- Official TeamSpeak 3 Client: joins the server like a normal client.
- ClientQuery addon: lets the Kotlin bot control the TeamSpeak client.
- Xvfb: fake display server so the GUI TeamSpeak client can run headlessly.
- PulseAudio: creates a virtual audio sink/source so music becomes the bot microphone.
- D-Bus: session bus used by players and media controls.
- mpv and yt-dlp: stream YouTube, SoundCloud, and Bandcamp audio.
- Web dashboard: local browser UI on `http://localhost:8080`.

## Current Verified Setup

This is the setup verified during implementation:

```env
TS3_SERVER_ADDRESS=viscous-salmon.gl.at.ply.gg
TS3_SERVER_PORT=53645
TS3_SERVER_PASSWORD=
TS3_CHANNEL_NAME=General 1
TS3_CHANNEL_PASSWORD=
TS3_NICKNAME=UC Music Bot
TS3_ACCEPT_TS_LICENSE=true
TS3_USE_OFFICIAL_TSCLIENT=true
TS3_SPOTIFY_PLAYER=disabled
TS3_COMMAND_PREFIX=!
TS3_PLAY_COMMAND=play
TS3_QUEUE_LIST_COMMAND=queue
TS3_QUEUE_SKIP_COMMAND=skip
TS3_QUEUE_STOP_COMMAND=stop
TS3_QUEUE_PAUSE_COMMAND=pause
TS3_QUEUE_RESUME_COMMAND=resume
TS3_QUEUE_NOWPLAYING_COMMAND=nowplaying
TS3_LOOP_COMMAND=loop
TS3_LOOP_QUEUE_COMMAND=loopqueue
TS3_LOOP_OFF_COMMAND=loopoff
TS3_LOOP_STATUS_COMMAND=loopstatus
TS3_VOLUME_COMMAND=volume
TS3_VOLUME_SHORT_COMMAND=vol
TS3_VOLUME_UP_COMMAND=volumeup
TS3_VOLUME_UP_SHORT_COMMAND=volup
TS3_VOLUME_DOWN_COMMAND=volumedown
TS3_VOLUME_DOWN_SHORT_COMMAND=voldown
TS3_VOLUME_MUTE_COMMAND=mute
```

Important: keep the host and port separate. Do not put `:53645` in `TS3_SERVER_ADDRESS`; put it in `TS3_SERVER_PORT`.

## Install Requirements

Install one of these:

- Windows or macOS: Docker Desktop.
- Linux server/VPS: Docker Engine and Docker Compose.

After installing Docker Desktop on Windows, start Docker Desktop and wait until it says Docker is running.

## First-Time Setup

Open PowerShell or a terminal in the project folder:

```powershell
cd C:\Users\hmiku3\Desktop\ts3-musicbot
```

Run the setup wizard:

```powershell
.\setup.ps1
```

The wizard checks Docker, creates or updates `.env`, prompts for the universal connection settings, and builds the bot image. It asks for:

- Bot nickname, for example `UC Music Bot`.
- TeamSpeak server address. You can type only the host or `host:port`, for example `viscous-salmon.gl.at.ply.gg:53645`.
- TeamSpeak server port. If you typed `host:port`, the wizard fills this in for you.
- TeamSpeak server password. Press Enter if the server has no password.
- TeamSpeak channel name, for example `General 1`.
- TeamSpeak channel password. Press Enter if the channel has no password.

If `.env` already exists, the wizard asks whether you want to update those settings. Press Enter at any prompt to keep the current value. For password prompts, type `clear` if you need to remove an old password.

The wizard also keeps these beginner-friendly defaults enabled:

```env
TS3_ACCEPT_TS_LICENSE=true
TS3_USE_OFFICIAL_TSCLIENT=true
TS3_SPOTIFY_PLAYER=disabled
TS3_COMMAND_PREFIX=!
```

Manual setup is still supported. If you do not want to use the wizard, create your `.env` file:

```powershell
Copy-Item .env.example .env
```

Then edit `.env` and set your TeamSpeak details. For the current server, use:

```env
TS3_SERVER_ADDRESS=viscous-salmon.gl.at.ply.gg
TS3_SERVER_PORT=53645
TS3_SERVER_PASSWORD=
TS3_NICKNAME=UC Music Bot
TS3_CHANNEL_NAME=General 1
TS3_CHANNEL_PASSWORD=
TS3_ACCEPT_TS_LICENSE=true
TS3_USE_OFFICIAL_TSCLIENT=true
TS3_SPOTIFY_PLAYER=disabled
TS3_COMMAND_PREFIX=!
TS3_PLAY_COMMAND=play
TS3_QUEUE_LIST_COMMAND=queue
TS3_QUEUE_SKIP_COMMAND=skip
TS3_QUEUE_STOP_COMMAND=stop
TS3_QUEUE_PAUSE_COMMAND=pause
TS3_QUEUE_RESUME_COMMAND=resume
TS3_QUEUE_NOWPLAYING_COMMAND=nowplaying
TS3_LOOP_COMMAND=loop
TS3_LOOP_QUEUE_COMMAND=loopqueue
TS3_LOOP_OFF_COMMAND=loopoff
TS3_LOOP_STATUS_COMMAND=loopstatus
TS3_VOLUME_COMMAND=volume
TS3_VOLUME_SHORT_COMMAND=vol
TS3_VOLUME_UP_COMMAND=volumeup
TS3_VOLUME_UP_SHORT_COMMAND=volup
TS3_VOLUME_DOWN_COMMAND=volumedown
TS3_VOLUME_DOWN_SHORT_COMMAND=voldown
TS3_VOLUME_MUTE_COMMAND=mute
```

Build and start the bot:

```powershell
docker compose up -d --build ts3-musicbot
```

Watch the logs:

```powershell
docker logs -f ts3-musicbot
```

A healthy startup looks like this:

```text
PulseAudio is ready.
Starting TS3 Music Bot...
Connecting to server at: viscous-salmon.gl.at.ply.gg, port 53645.
Server name: Unknown Cyberia
Audio setup done.
Attempting to join a channel at "General 1"
Bot UC Music Bot started listening to the chat in channel General 1.
```

Open the dashboard:

```text
http://localhost:8080
```

## Using The Bot In TeamSpeak

Type commands in the TeamSpeak channel chat, not the Docker terminal.

Use `!` commands, not `/` commands. TeamSpeak slash commands are usually handled by the TeamSpeak client itself, while `!play` is just a normal chat message that the bot can read.

Quick start:

```text
!play never gonna give you up
!play https://youtu.be/dQw4w9WgXcQ
!queue
!skip
!pause
!resume
!volume 60
!health
!history
!replay
!seek 1:30
!loop
!loopqueue
!stop
!nowplaying
!help
```

`!play` searches YouTube first and can also play direct YouTube, SoundCloud, or Bandcamp links. Spotify is skipped when `TS3_SPOTIFY_PLAYER=disabled`. When a result is found, the bot posts the matched track name/link, adds it to the queue, and starts the queue only if nothing is already playing.

`!stop` stops the queue and also kills any leftover `mpv` playback process. `!skip` skips the currently playing song instantly.

Everyone can use the bot by default. Permission settings are optional; leave them blank if you want all users in the bot's voice channel to be able to add and control music.

The bot only accepts commands from users in the same TeamSpeak voice channel as the bot. If the bot is in `General 1`, someone sitting in `General 2` cannot control it from there.

Audio quality is tuned for music playback through `mpv` with `bestaudio/best`, PulseAudio output, 48 kHz stereo, and a larger demuxer cache. TeamSpeak can still compress the final microphone stream, so use the TeamSpeak server/channel codec `Opus Music` with a high quality/bitrate if you control the server settings.

## Permissions

By default, everyone in the same voice channel as the bot can use it. You do not need to configure permissions for a normal friends/server setup.

Permission variables are only needed if you want to restrict commands later. Leave these blank for everyone:

```env
TS3_MUSIC_PERMISSION_NICKNAMES=
TS3_MUSIC_PERMISSION_SERVER_GROUPS=
TS3_MUSIC_PERMISSION_CHANNEL_GROUPS=
TS3_ADMIN_PERMISSION_NICKNAMES=
TS3_ADMIN_PERMISSION_SERVER_GROUPS=
TS3_ADMIN_PERMISSION_CHANNEL_GROUPS=
TS3_OWNER_NICKNAMES=
TS3_COMMAND_COOLDOWN_SECONDS=3
```

What each permission means:

| Permission | Blank default | When configured |
| --- | --- | --- |
| Music permission | Everyone can use `!play`, `!queue-add`, `!queue-playnext`, `!queue-playnow`, and `!replay`. | Only matching nicknames/groups can add music. |
| Admin/control permission | Everyone can use normal control commands. | Only matching admins/owners can use restricted control commands. |
| Track requester | The user who added the current track. | The requester can `!skip` their own track instantly. |

Nickname examples:

```env
TS3_MUSIC_PERMISSION_NICKNAMES=Alice,Bob
TS3_ADMIN_PERMISSION_NICKNAMES=YourNickname
TS3_OWNER_NICKNAMES=YourNickname
```

Group ID examples:

```env
TS3_MUSIC_PERMISSION_SERVER_GROUPS=6,12
TS3_ADMIN_PERMISSION_SERVER_GROUPS=6
TS3_MUSIC_PERMISSION_CHANNEL_GROUPS=5
```

To find TeamSpeak group IDs, use the TeamSpeak client permissions windows or ask a server admin. Server group IDs and channel group IDs are numbers. Group names can change, but IDs are stable.

Permission examples:

```text
!play never gonna give you up
```

If music permission is blank, this works for everyone. If music permission is configured and the user is not allowed, the bot replies:

```text
You do not have permission to add music.
```

Smart skip examples:

```text
!skip
```

- If the current track requester runs `!skip`, the song skips instantly.
- If an admin/control user runs `!skip`, the song skips instantly.
- If another listener runs `!skip`, it becomes a vote.
- If there are 3 users in the bot's voice channel, not counting the bot, 2 votes are required.
- A user can only vote once per track.
- Users have a small command cooldown by default to reduce spam. Set `TS3_COMMAND_COOLDOWN_SECONDS=0` to disable it.

## Chat Command Reference

All commands use the configured prefix. These examples assume `TS3_COMMAND_PREFIX=!`.

### Main Commands

| Command | What it does |
| --- | --- |
| `!help` | Shows the built-in command help. |
| `!help play` | Shows help for one command. `!help !play` also works. |
| `!play <query or link>` | Searches without Spotify/API keys, shows the matched track, adds it to the queue, and starts playback if idle. |
| `!health` | Shows bot status, current track, queue size, loop mode, volume, active channel, player state, requester, and skip votes. |
| `!info <query or link>` | Shows information about a link or search query. |
| `!search <service> <type> <text>` | Searches a specific service/type. |

Search services include `youtube`/`yt`, `soundcloud`/`sc`, and `bandcamp`/`bc`. Spotify search is only useful if Spotify is configured.

Examples:

```text
!play daft punk one more time
!search youtube video daft punk one more time
!search soundcloud track synthwave mix --limit 5
!info https://youtu.be/dQw4w9WgXcQ
```

### Queue Commands

| Command | What it does |
| --- | --- |
| `!queue-add <link or service search>` | Adds tracks to the end of the queue. |
| `!queue-playnext <link or service search>` | Adds tracks to the top of the queue. |
| `!queue-playnow <link or service search>` | Adds tracks to the top and starts playback now. |
| `!queue-play` | Starts playing the queue. |
| `!queue` | Lists the queue. This is aliased from `queue-list` in Docker. |
| `!queue-delete <position or link>` | Removes tracks from the queue. |
| `!clear` | Clears the queue. This is aliased from `queue-clear` in Docker. |
| `!shuffle` | Shuffles the queue. |
| `!skip` | Skips the currently playing song instantly. |
| `!queue-move <position/link> -p <new position>` | Moves a queued track. |
| `!stop` | Stops queue playback. |
| `!queue-status` | Shows queue state. |
| `!nowplaying` | Shows the current track. |
| `!pause` | Pauses queue playback. |
| `!resume` | Resumes queue playback. |
| `!seek <seconds|m:ss|h:mm:ss>` | Seeks within the current track, for example `!seek 90` or `!seek 1:30`. |
| `!history` | Shows recently played tracks and requesters. |
| `!replay` | Adds the last played track back to the queue. |
| `!queue-repeat` | Adds the current song back to the top of the queue. |
| `!loop` | Toggles current-track loop. The same song restarts when it ends. |
| `!loop on` / `!loop off` | Explicitly turns current-track loop on/off. |
| `!loopqueue` | Toggles whole-queue loop. Finished songs go to the end of the queue. |
| `!loopqueue on` / `!loopqueue off` | Explicitly turns whole-queue loop on/off. |
| `!loopoff` | Turns all loop modes off. |
| `!loopstatus` | Shows the current loop mode. |
| `!volume` / `!vol` | Shows the current live player volume. |
| `!volume <0-150>` / `!vol <0-150>` | Sets live player volume by percentage. Larger numbers are clamped to 150%. |
| `!volume up` / `!volume down` | Raises or lowers volume by 10. |
| `!volume +10` / `!volume -10` | Raises or lowers volume by a custom amount. |
| `!volumeup` / `!volup` | Raises volume by 10, or by a given amount. |
| `!volumedown` / `!voldown` | Lowers volume by 10, or by a given amount. |
| `!mute` | Sets live player volume to 0. |

Examples:

```text
!queue-add youtube video haken initiate
!queue-playnext https://soundcloud.com/artist/track
!queue-playnow bandcamp track celeste soundtrack
!queue --limit 20
!queue-delete 3
!queue-move 5 -p 0
!queue-repeat -a 3
!loop on
!loopqueue
!volume 65
!volup 15
!voldown
```

### Channel Commands

| Command | What it does |
| --- | --- |
| `!goto <channel path>` | Moves the bot to another channel. |
| `!goto <channel path> -p <password>` | Moves to a password-protected channel. |
| `!return` | Moves the bot back to the original channel. |



## Customizing Commands

Commands are generated from `.env` into `/home/ts3bot/ts3-musicbot.commands` when the container starts.

Change command names in `.env`, then recreate the container:

```powershell
docker compose up -d --force-recreate ts3-musicbot
```

Available command environment variables:

```env
TS3_COMMAND_PREFIX=!
TS3_HELP_COMMAND=help
TS3_PLAY_COMMAND=play
TS3_QUEUE_ADD_COMMAND=queue-add
TS3_QUEUE_PLAYNEXT_COMMAND=queue-playnext
TS3_QUEUE_PLAYNOW_COMMAND=queue-playnow
TS3_QUEUE_PLAY_COMMAND=queue-play
TS3_QUEUE_LIST_COMMAND=queue
TS3_QUEUE_DELETE_COMMAND=queue-delete
TS3_QUEUE_CLEAR_COMMAND=clear
TS3_QUEUE_SHUFFLE_COMMAND=shuffle
TS3_QUEUE_SKIP_COMMAND=skip
TS3_QUEUE_MOVE_COMMAND=queue-move
TS3_QUEUE_STOP_COMMAND=stop
TS3_QUEUE_STATUS_COMMAND=queue-status
TS3_QUEUE_NOWPLAYING_COMMAND=nowplaying
TS3_QUEUE_PAUSE_COMMAND=pause
TS3_QUEUE_RESUME_COMMAND=resume
TS3_QUEUE_REPEAT_COMMAND=queue-repeat
TS3_HEALTH_COMMAND=health
TS3_SEEK_COMMAND=seek
TS3_HISTORY_COMMAND=history
TS3_REPLAY_COMMAND=replay
TS3_LOOP_COMMAND=loop
TS3_LOOP_QUEUE_COMMAND=loopqueue
TS3_LOOP_OFF_COMMAND=loopoff
TS3_LOOP_STATUS_COMMAND=loopstatus
TS3_VOLUME_COMMAND=volume
TS3_VOLUME_SHORT_COMMAND=vol
TS3_VOLUME_UP_COMMAND=volumeup
TS3_VOLUME_UP_SHORT_COMMAND=volup
TS3_VOLUME_DOWN_COMMAND=volumedown
TS3_VOLUME_DOWN_SHORT_COMMAND=voldown
TS3_VOLUME_MUTE_COMMAND=mute
TS3_INFO_COMMAND=info
TS3_SEARCH_COMMAND=search
TS3_GOTO_COMMAND=goto
TS3_RETURN_COMMAND=return
```

Do not include the `!` in individual command names. Use `TS3_COMMAND_PREFIX=!` once, then set names like `TS3_PLAY_COMMAND=play`.

## Docker Commands

Check status:

```powershell
docker compose ps
```

Follow logs:

```powershell
docker logs -f ts3-musicbot
```

Show recent logs:

```powershell
docker logs --tail 200 ts3-musicbot
```

Start:

```powershell
docker compose up -d ts3-musicbot
```

Stop:

```powershell
docker compose down
```

Restart the already-created container:

```powershell
docker compose restart ts3-musicbot
```

Recreate after changing `.env`:

```powershell
docker compose up -d --force-recreate ts3-musicbot
```

Rebuild after changing `Dockerfile`, `entrypoint.sh`, Kotlin source, or `web_ui.py`:

```powershell
docker compose up -d --build ts3-musicbot
```

Open a shell inside the container:

```powershell
docker exec -it ts3-musicbot bash
```

View generated bot config:

```powershell
docker exec ts3-musicbot bash -lc "cat /home/ts3bot/ts3-musicbot.config"
```

View generated command config:

```powershell
docker exec ts3-musicbot bash -lc "cat /home/ts3bot/ts3-musicbot.commands"
```

## Troubleshooting

### PulseAudio Permission Denied For `/root/.config/pulse/daemon.conf`

Symptom:

```text
Permission denied: /root/.config/pulse/daemon.conf
```

Cause: PulseAudio is starting with root's home/config environment while the container is supposed to run audio as `ts3bot`.

Fix:

```powershell
docker compose down
docker compose up -d --build ts3-musicbot
docker logs --tail 80 ts3-musicbot
```

Working logs should say:

```text
Preparing ts3bot runtime directories...
Starting PulseAudio daemon...
PulseAudio is ready.
```

### Stuck On `Waiting for TeamSpeak to install ClientQuery addon`

The bot now times out instead of looping forever. Check the TeamSpeak client output:

```powershell
docker exec ts3-musicbot bash -lc "tail -80 /tmp/tsOutput.log"
```

If you see a missing library or Qt error, rebuild the image:

```powershell
docker compose up -d --build ts3-musicbot
```

Check missing TeamSpeak binary libraries:

```powershell
docker exec ts3-musicbot bash -lc "ldd /opt/teamspeak3/ts3client_linux_amd64 | grep 'not found' || true"
```

Check missing Qt/XCB plugin libraries:

```powershell
docker exec ts3-musicbot bash -lc "ldd /opt/teamspeak3/platforms/libqxcb.so | grep 'not found' || true"
```

No output means the dependency check passed.

### Qt Error: `Could not load the Qt platform plugin "xcb"`

Symptom:

```text
qt.qpa.plugin: Could not load the Qt platform plugin "xcb" in "" even though it was found.
```

Cause: the TeamSpeak GUI client needs Qt/XCB runtime packages even when running headlessly under Xvfb.

Fix:

```powershell
docker compose up -d --build ts3-musicbot
```

The Dockerfile includes the needed XCB packages such as `libxcb-icccm4`, `libxcb-image0`, `libxcb-keysyms1`, `libxcb-render-util0`, `libxcb-xinerama0`, `libxcb-shape0`, `libxcb-sync1`, `libxcb-xfixes0`, and `libxcb-xkb1`.

### Missing Shared Libraries

Symptoms may include:

```text
libevent-2.1.so.7: cannot open shared object file
libpci.so.3: cannot open shared object file
libxslt.so.1: cannot open shared object file
libatomic.so.1: cannot open shared object file
```

Fix:

```powershell
docker compose up -d --build ts3-musicbot
```

These dependencies are installed by the Dockerfile.

### Bot Connects To Server But Not The Channel

Check these `.env` values:

```env
TS3_CHANNEL_NAME=General 1
TS3_CHANNEL_PASSWORD=
```

The channel name must match TeamSpeak exactly, including spaces and capitalization. If there are duplicate channel names on the server, move the bot manually once or configure `TS3_CHANNEL_FILE_PATH` after you know the generated channel chat file path.

### Bot Cannot Connect To Server

Check that:

- `TS3_SERVER_ADDRESS` is only the host, for example `viscous-salmon.gl.at.ply.gg`.
- `TS3_SERVER_PORT` is only the port, for example `53645`.
- Server password is blank only if the server has no password.
- The server is online and accepts normal TeamSpeak 3 clients.
- Docker has network access.

Useful command:

```powershell
docker logs --tail 120 ts3-musicbot
```

### Bot Joins But Nobody Hears Music

Check in TeamSpeak:

- The bot is not muted.
- The bot has permission to talk in the channel.
- Your client is not locally muting the bot.
- The current track is actually playing.

Check PulseAudio inside Docker:

```powershell
docker exec ts3-musicbot bash -lc "pactl info && pactl list short sinks && pactl list short sources"
```

Expected default devices:

```text
Default Sink: VirtualSink
Default Source: VirtualSink.monitor
```

Restart if audio routing looks wrong:

```powershell
docker compose restart ts3-musicbot
```

### `!play` Finds Nothing Or YouTube Fails

Try:

```text
!play https://youtu.be/dQw4w9WgXcQ
!play soundcloud.com/artist/track
!play bandcamp artist song
```

Common causes:

- The video requires login, age verification, or region access.
- YouTube changed extraction behavior and yt-dlp needs an update.
- The query is too vague.
- The server/network temporarily blocked the source.

Rebuild to fetch the latest yt-dlp:

```powershell
docker compose up -d --build ts3-musicbot
```

YouTube API keys are optional. Normal `!play` does not require one.

### A User Cannot Use `!play`

By default, everyone can use `!play`. If someone is denied, check whether you configured music permission variables:

```env
TS3_MUSIC_PERMISSION_NICKNAMES=
TS3_MUSIC_PERMISSION_SERVER_GROUPS=
TS3_MUSIC_PERMISSION_CHANNEL_GROUPS=
```

If any of those are set, only matching users can add music. Clear them to let everyone use the bot again, then recreate:

```powershell
docker compose up -d --force-recreate ts3-musicbot
```

### `!skip` Votes Look Wrong

`!skip` uses the users currently in the bot's TeamSpeak voice channel, excluding the bot.

- 1 user means 1 vote required.
- 2 users means 2 votes required.
- 3 users means 2 votes required.
- 4 users means 3 votes required.

If the requester of the current track runs `!skip`, it skips instantly. If another user runs `!skip`, it counts as a vote unless they are configured as admin/control.

### `!play` Replaces The Current Song Instead Of Queuing

Expected behavior:

- If nothing is playing, `!play <query>` queues the found result and starts it.
- If a song is already playing, `!play <query>` queues the found result after the current queue.
- Use `!queue` to confirm the next songs waiting.
- Use `!queue-playnow <link or service search>` only when you intentionally want to interrupt and play something now.

If `!play` still interrupts playback after rebuilding, make sure the container is running the newest image:

```powershell
docker compose up -d --build --force-recreate ts3-musicbot
```

### `!stop` Does Not Stop Audio

`!stop` is mapped to the queue stop command and now also stops `mpv` directly. If audio continues:

```powershell
docker compose logs --tail=100 ts3-musicbot
docker compose restart ts3-musicbot
```

If the problem returns, check that your generated command file maps `queue-stop` to `!stop`:

```powershell
docker compose exec ts3-musicbot grep queue-stop /home/ts3bot/ts3-musicbot.commands
```

### Audio Sounds Bad

The bot requests high-quality source audio from `yt-dlp`/`mpv`, then TeamSpeak re-encodes it as microphone audio. Best results:

- Set the TeamSpeak channel codec to `Opus Music`.
- Use the highest codec quality your server allows.
- Keep Docker startup volumes around `50` to `75`, then adjust live with `!volume 60`.
- Avoid pushing `!volume` above `100` unless the source is very quiet, because TeamSpeak may clip.
- Verify PulseAudio is using the virtual sink:

```powershell
docker compose exec ts3-musicbot pactl info
```

### Dashboard Does Not Open

The dashboard runs on:

```text
http://localhost:8080
```

If port `8080` is already used, change the left side of this line in `docker-compose.yml`:

```yaml
ports:
  - "8080:8080"
```

For example:

```yaml
ports:
  - "8081:8080"
```

Then recreate:

```powershell
docker compose up -d --force-recreate ts3-musicbot
```

Open:

```text
http://localhost:8081
```

### Docker Desktop Or WSL Issues On Windows

Try:

- Start Docker Desktop first.
- Restart Docker Desktop.
- Run PowerShell from the project folder.
- Make sure the project is in a folder Docker can access.
- Rebuild after any line-ending or script changes:

```powershell
docker compose up -d --build ts3-musicbot
```

The Dockerfile normalizes script line endings with `sed`, so Windows CRLF files should not break the container.

### Clean Reset

Only do this if the TeamSpeak client config/cache is corrupted or you want a fresh first-run state.

Warning: this deletes persisted TeamSpeak client state and Spotify cache/config volumes.

```powershell
docker compose down
docker volume rm ts3_bot_config ts3_spotify_cache ts3_spotify_config
docker compose up -d --build ts3-musicbot
```

## FAQ

### Do I need Spotify Premium?

No for YouTube, SoundCloud, and Bandcamp playback. Keep `TS3_SPOTIFY_PLAYER=disabled`. Spotify playback itself usually requires Spotify Premium.

### Do I need API keys?

No for normal `!play` usage. `!play` uses yt-dlp/mpv and can search/play without YouTube or Spotify keys.

### Why does the bot use TeamSpeak's official client?

TeamSpeak audio capture is easiest and most compatible when the bot behaves like a real TeamSpeak client. The container hides the GUI inside Xvfb and routes the audio through PulseAudio.

### Should I type `/play` or `!play`?

Use `!play`. Slash commands are TeamSpeak client commands and may not reach the channel chat as normal messages.

### Do I need to run Gradle manually?

No. Docker builds the Kotlin application inside the builder stage. For normal use, run Docker Compose commands only.

### Can I run this on a VPS?

Yes, as long as Docker is installed and the VPS can connect to your TeamSpeak server and music sources.

### Can I close the terminal?

Yes if the container was started with `docker compose up -d`. Docker keeps it running in the background. Docker Desktop or Docker Engine still needs to stay running.

### Where are settings stored?

- Your editable settings live in `.env`.
- Generated runtime settings live inside the container at `/home/ts3bot/ts3-musicbot.config`.
- Generated command settings live inside the container at `/home/ts3bot/ts3-musicbot.commands`.
- TeamSpeak client state is stored in the Docker volume `ts3_bot_config`.

## Recommended Future Improvements

These are not required for the bot to work, but they would make it nicer to use on a real TeamSpeak server:

| Improvement | Why it helps |
| --- | --- |
| `!seek <time>` | Jump to a timestamp in the current song. |
| `!forward <seconds>` / `!rewind <seconds>` | Quick playback control without restarting a track. |
| `!remove <position>` alias | Easier than remembering `!queue-delete`. |
| `!move <from> <to>` alias | Easier queue reordering for normal users. |
| `!history` | Shows recently played tracks so users can replay something. |
| `!replay` | Adds the last played/current song back to the queue. |
| `!savequeue <name>` / `!loadqueue <name>` | Lets a server keep favorite playlists. |
| Music/admin permissions | Lets only approved users add music, while track requesters and admins can control sensitive actions. |
| Smart `!skip` voting | Makes `!skip` instantly skip for the track requester/admin, but count as a majority vote for everyone else. |
| Per-user cooldowns | Prevents command spam or accidental queue floods. |
| Auto-disconnect idle timer | Marks the bot idle after a long time with no playback. |
| Better error messages for blocked YouTube videos | Explains age/region/login failures more clearly. |
| Health command, for example `!health` | Reports queue state, player status, volume, loop mode, and audio routing. |

## Better Prompt For Future Changes

Use this prompt when asking an AI agent or developer to continue this project:

```text
Implement and test a Dockerized TeamSpeak 3 music bot.

Server:
- Address: viscous-salmon.gl.at.ply.gg
- Port: 53645
- Channel: General 1
- Bot nickname: UC Music Bot
- Server password: none
- Channel password: none

Music behavior:
- Command prefix must be !
- Main user command must be !play <query or link>
- !play should work without API keys.
- !play should show what track it found, add it to the queue, and only start playback when the queue is idle.
- Search/play from YouTube first, then support SoundCloud and Bandcamp direct links or fallback search.
- Skip Spotify because I do not have Spotify Premium.
- Add live controls for !queue, !skip, !pause, !resume, !stop, !nowplaying, !volume, !volup, !voldown, !mute, !loop, !loopqueue, !loopoff, and !loopstatus.
- !stop must stop the queue and any leftover mpv process.
- !skip must skip the current track, and if there is no next track it should stop the current track cleanly.
- Add configurable music permissions, but leave the default open so everyone can use !play unless permissions are configured.
- Track who requested each queued/current track. The requester gets control over their own track.
- Replace separate !voteskip behavior with smart !skip behavior: requester/admin skips instantly; other users vote.
- Vote skip threshold is majority of users in the bot's current voice channel, excluding the bot. Example: 3 users means 2 votes required.
- Add !leave and !join. If the bot is already active in a voice channel, !join should say the bot is already in a voice channel and the user must run !leave first.
- Only accept commands from users who are in the same TeamSpeak voice channel as the bot. A user in General 2 must not control the bot while the bot is active in General 1.
- After !leave, the bot should be idle and reject music/control commands until !join claims it again.
- Improve music quality by using bestaudio/best, PulseAudio output, 48 kHz stereo, reasonable caching, and clear docs that TeamSpeak Opus Music/high codec quality is needed server-side.

Docker requirements:
- Run the official TeamSpeak 3 client headlessly with Xvfb.
- Route audio through PulseAudio VirtualSink into TeamSpeak microphone input.
- Run audio, D-Bus, and TeamSpeak state as the non-root ts3bot user.
- Do not preserve root HOME/XDG config variables when launching PulseAudio or the bot.
- Include mpv, yt-dlp, OpenJDK, OpenJFX, D-Bus, PulseAudio, and all TeamSpeak/Qt/XCB runtime libraries.
- Expose the web dashboard on localhost:8080.

Reliability requirements:
- Fix PulseAudio boot loops such as Permission denied on /root/.config/pulse/daemon.conf.
- Fix TeamSpeak missing libraries such as libevent-2.1.so.7, libpci.so.3, libxslt.so.1, and libatomic.so.1.
- Fix Qt/XCB startup failures such as Could not load the Qt platform plugin "xcb".
- Do not let ClientQuery installation wait forever; time out with useful logs.

Files to update:
- Dockerfile
- entrypoint.sh
- docker-compose.yml
- .env.example
- README.docker.md
- Kotlin source/tests if required

Verification:
- Run bash -n entrypoint.sh.
- Run docker compose config.
- Run docker compose up -d --build ts3-musicbot.
- Confirm logs show PulseAudio is ready, TeamSpeak connects, audio setup completes, and the bot starts listening in General 1.
- Document all setup steps, commands, troubleshooting, and FAQs for a beginner.
```

## Better Prompt For Permission And Skip Voting

Use this prompt when implementing music permissions, track ownership, and smart skip voting:

```text
Implement music permissions, track ownership, smart !skip voting, and beginner-friendly documentation for this Dockerized TeamSpeak 3 music bot.

Core behavior:
- Prefix is !.
- Everyone can use !play by default.
- Music permission must be configurable in .env and documented. Prefer TeamSpeak server group IDs/names or channel group IDs/names.
- If music permissions are configured, users without permission should get a clear chat message, for example: "You do not have permission to add music."
- Store the requester/owner for each track added through !play and queue commands.
- The requester of the currently playing track has extra control over that track.
- Admin/control users have extra control over all tracks.

Smart !skip behavior:
- Remove the need for a separate !voteskip command in normal usage.
- !skip should decide automatically:
  - If the user is the requester of the current track, skip instantly.
  - If the user is an admin/control user, skip instantly.
  - Otherwise, count !skip as a vote skip.
- Vote threshold is majority of users currently in the same voice channel as the bot, excluding the bot.
- Formula: requiredVotes = floor(listenerCount / 2) + 1.
- Example: if 3 users are in the channel, excluding the bot, 2 votes are required.
- A user can only vote once per current track.
- Clear skip votes when the track changes, stops, or is skipped.
- Chat should show progress, for example: "Skip vote added: 1/2 votes."

Permission rules:
- Normal users can use !help, !queue, !nowplaying, !health, !volume status, and !skip as a vote.
- Music-permission users can use !play and add songs.
- Track requesters can skip/pause/resume/seek/replay their own current track if implemented.
- Admin/control users can use dangerous commands such as !stop, !clear, !leave, !join, and force skip.
- If a command is denied, explain why and what permission is needed.

Commands to add or update:
- !health: show bot status, active channel, current track, requester, queue size, loop mode, volume, player state, and audio route if available.
- !seek <time>: seek within the current track. Accept 90, 1:30, and 01:30.
- !history: show recently played tracks and requesters.
- !replay: add the last played track back to the queue.
- Optional: cooldowns to prevent command spam.

README / documentation requirements:
- Update README.docker.md like a beginner has never used Docker, TeamSpeak bots, or permissions before.
- Add a "Permissions" section explaining music permission, admin/control permission, and track requester ownership.
- Add an .env example for every new permission setting.
- Explain how to find TeamSpeak server group IDs/channel group IDs if group IDs are used.
- Add a table showing which role can use each command.
- Add examples:
  - Allowed user runs !play.
  - Denied user runs !play.
  - Requester runs !skip and it skips instantly.
  - Non-requester runs !skip and it becomes a vote.
  - 3 users in channel means 2 votes required.
- Add troubleshooting for:
  - User should have permission but is denied.
  - Votes never reach the threshold.
  - Bot counts the wrong number of users.
  - !skip skips instantly when it should vote.
  - !skip votes when it should skip instantly.
- Document whether !voteskip is removed, deprecated, or kept only as an alias to !skip.

Reliability requirements:
- Do not retry the same failing Docker or Gradle command repeatedly.
- Use short timeouts.
- If Docker Desktop is unavailable, do static code/config review and clearly say runtime verification is blocked.
- Keep changes scoped and update tests where practical.

Verification:
- Run bash -n entrypoint.sh.
- Run docker compose config.
- Run one build only if Docker is available.
- If runtime is available, start the bot and verify logs show PulseAudio ready, TeamSpeak connected, audio setup done, and bot listening in the configured channel.
- End with what was implemented, what was documented, what was tested, and what still needs manual TeamSpeak verification.
```

## Better Prompt For Bug Audits

Use this prompt when you want someone to check what is missing, find bugs, and suggest useful upgrades without getting stuck in long rebuild loops:

```text
Audit this Dockerized TeamSpeak 3 music bot for missing features, bugs, and practical improvements.

Important:
- Do not get stuck retrying the same failing command.
- Use short timeouts for Docker, Gradle, and network checks.
- If Docker Desktop or the TeamSpeak server is unavailable, switch to static code/config review and clearly say runtime verification is blocked.
- Separate findings into: fix now, verify manually, and future improvements.

Expected bot behavior:
- Prefix is !.
- !play <query or link> searches YouTube first, skips Spotify, falls back to SoundCloud/Bandcamp when possible, shows the found track, queues it, and starts only if idle.
- !stop stops queue playback and any leftover mpv process.
- !skip skips the current track or stops it cleanly when nothing else is queued.
- !volume, !volup, !voldown, and !mute control live playback volume.
- !loop, !loopqueue, !loopoff, and !loopstatus work.
- !leave marks the bot idle, and !join claims/moves it again.
- The bot only accepts music/control commands from users in the same TeamSpeak voice channel as the bot.

Checks to run when available:
- bash -n entrypoint.sh
- docker compose config
- docker compose build ts3-musicbot, only once after code changes
- docker compose up -d --force-recreate ts3-musicbot
- docker compose logs --tail=150 ts3-musicbot

Deliverables:
- Patch small confirmed bugs directly.
- Do not implement large new features without listing the design first.
- Update README.docker.md if behavior, commands, setup, or troubleshooting changes.
- End with a short summary of what was checked, what was fixed, what could not be verified, and the best next improvements.
```
