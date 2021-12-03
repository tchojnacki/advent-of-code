/**
 * Given a list of correct command strings, dispatch [action] taking command name and argument on each of them.
 * @param commands list of valid command strings
 * @param action function taking a string (command name) and integer (argument) that gets called for each command
 */
fun dispatchCommands(commands: List<String>, action: (command: String, argument: Int) -> Unit) {
    for (line in commands) {
        val parts = line.split(" ")
        val command = parts[0]
        val argument = parts[1].toInt()

        action(command, argument)
    }
}

fun main() {
    fun part1(input: List<String>): Int {
        var horizontal = 0
        var depth = 0

        dispatchCommands(input) { command, argument ->
            when (command) {
                "forward" -> horizontal += argument
                "down" -> depth += argument
                "up" -> depth -= argument
            }
        }

        return horizontal * depth
    }

    fun part2(input: List<String>): Int {
        var horizontal = 0
        var depth = 0
        var aim = 0

        dispatchCommands(input) { command, argument ->
            when (command) {
                "forward" -> {
                    horizontal += argument
                    depth += aim * argument
                }
                "down" -> aim += argument
                "up" -> aim -= argument
            }
        }

        return horizontal * depth
    }

    val testInput = readInputAsLines("Day02_test")
    check(part1(testInput) == 150)
    check(part2(testInput) == 900)

    val input = readInputAsLines("Day02")
    println(part1(input))
    println(part2(input))
}
