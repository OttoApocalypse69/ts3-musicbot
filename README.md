TS3 MusicBot lets you control and listen to your music from a TeamSpeak server's channel via the chat.<br>
<br>
TS3 MusicBot can play music from Spotify, YouTube, SoundCloud and Bandcamp. Support for other services possibly coming in the future.<br>
TS3 MusicBot doesn't require you to be an admin on the server you are using the bot on, you only need permission to speak in the desired channel and use the chat.<br>
<br>
<h4>Features:</h4>

- Spotify Support! Unlike other bots, this Spotify support is legit!*<br>
- YouTube Support.<br>
- SoundCloud Support.<br>
- Bandcamp Support.
- Built in Spotify, YouTube and SoundCloud search.<br>
- You can have tracks from Spotify, YouTube, SoundCloud and Bandcamp all in the same queue!<br>
- Supports adding multiple tracks, albums and playlists etc. to the queue simultaneously.<br>
- Add whole playlists to the queue. This is something that isn't possible even in the official Spotify client!<br>
- Supports adding a Spotify artist's top tracks to the queue.<br>
- Queue-aware `!play` command — if a song is already playing, `!play` adds the new song to the end of the queue automatically!<br>
- Shuffle your queue at any time with `!shuffle`.<br>
- Loop the current track with `!loop`, or loop the entire queue (including newly added songs) with `!loopqueue`.<br>
- You can easily move tracks to any position in the queue.<br>
- Supports pre-shuffling. This makes it possible, for example, to shuffle a playlist before it gets added to the queue.<br>
- Supports ncspot! If you don't want to use the official Spotify client, you can use ncspot, which is a lot lighter on system resources, but it requires a Spotify premium account.<br>
- And more...
<br>
<h4>Requirements & Setup options:</h4>

- **Docker (Recommended - All Platforms):** Works out of the box on Windows, Linux, and macOS via containerized virtualization. On Windows, run `.\setup.ps1` to be prompted for the bot nickname, TeamSpeak server address, server password, and channel. Refer to the [Docker Setup & Tutorial Guide](README.docker.md) for quick-start commands.
- **Manual Installation (Linux/WSL2):** Requires manual PulseAudio virtual routing, tmux, xvfb, and JavaFX setup. Go to [Wiki](https://gitlab.com/Bettehem/ts3-musicbot/wikis/home) for manual instructions.<br>
<br>
<h4>Commands:</h4>

- All commands start with the `!` character by default. Enter them in the chat of the channel your bot is connected to.<br>
- **`!play <song name or link>`** — Search and play a song immediately. If a song is already playing, the new song is added to the end of the queue instead. Searches YouTube first, then SoundCloud and Bandcamp. Example: `!play never gonna give you up`.<br>
- **`!queue-list`** / **`!queue`** — Show the current song queue.<br>
- **`!skip`** — Skip the currently playing song.<br>
- **`!stop`** — Stop the queue.<br>
- **`!pause`** / **`!resume`** — Pause or resume playback.<br>
- **`!shuffle`** — Shuffle the current queue.<br>
- **`!loop`** — Toggle looping of the current track.<br>
- **`!loopqueue`** — Toggle looping of the entire queue. All songs, including newly added ones, will repeat until `!loopoff` is used.<br>
- **`!loopoff`** — Turn off all looping.<br>
- **`!loopstatus`** — Show the current loop mode.<br>
- **`!volume <0-150>`** / **`!vol`** — Get or set the playback volume.<br>
- **`!volumeup`** / **`!volup`** — Increase volume by 10%.<br>
- **`!volumedown`** / **`!voldown`** — Decrease volume by 10%.<br>
- **`!nowplaying`** — Show info on the currently playing track.<br>
- **`!queue-status`** — Show the current queue status (playing/paused/stopped).<br>
- **`!queue-clear`** — Clear the song queue.<br>
- **`!queue-delete <link or position>`** — Delete a specific song from the queue.<br>
- **`!queue-move <link or position> -p <new position>`** — Move a track to a new position in the queue.<br>
- **`!search <service> <type> <query>`** — Search a music service. Example: `!search bc track Haken Initiate`.<br>
- **`!info <link or search query>`** — Get info on a song, album, or artist.<br>
- **`!goto <channel path>`** — Move the bot to another channel.<br>
- **`!return`** — Return the bot to its original channel.<br>
- **`!help`** / **`!help <command>`** — Show help for all or a specific command.<br>
<br>
<br>
<br>
<br>

*Other bots which claim to support Spotify, will only search for a song's data on Spotify, then enter it in a YouTube search and play the first result. This is especially problematic if you're trying to play a Spotify song that doesn't exist on YouTube. What you will get is a random video (not your song!) that might just have a similar name as your song. And even if the bot happens to find the correct match for your song on YouTube, the audio quality might still be a lot worse on YouTube than on Spotify.<br>
This problem doesn't exist on this bot, as it will search for the relevant Spotify data using their API, and then uses either the official Spotify client, or if the user so chooses, ncspot to play the songs straight from Spotify.<br>
<br>
If you like my work and feel like it's worth your money, you can donate via PayPal. More options may come in the future. Thanks for your support!<br>
[![Support via PayPal](https://cdn.rawgit.com/twolfson/paypal-github-button/1.0.0/dist/button.svg)](https://www.paypal.me/Bettehem/)

