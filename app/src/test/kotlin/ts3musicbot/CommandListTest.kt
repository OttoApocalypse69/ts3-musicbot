package ts3musicbot

import ts3musicbot.util.CommandList
import kotlin.test.Test
import kotlin.test.assertEquals

class CommandListTest {
    @Test
    fun defaultCommandsUseBangPrefixAndSimplePlayCommand() {
        val commands = CommandList()

        assertEquals("!", commands.commandPrefix)
        assertEquals("!play", commands.commandList["play"])
        assertEquals("!help", commands.commandList["help"])
    }

    @Test
    fun customCommandsCanUseShortQueueAliases() {
        val commands = CommandList()

        commands.applyCustomCommands(
            "!",
            mapOf(
                "play" to "play",
                "queue-list" to "queue",
                "queue-skip" to "skip",
            ),
        )

        assertEquals("!play", commands.commandList["play"])
        assertEquals("!queue", commands.commandList["queue-list"])
        assertEquals("!skip", commands.commandList["queue-skip"])
        assertEquals("!queue-playnow", commands.commandList["queue-playnow"])
    }
}
