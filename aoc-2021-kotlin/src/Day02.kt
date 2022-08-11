object Day02 {
    private fun dispatchCommands(commands: List<String>, action: (command: String, argument: Int) -> Unit) {
        for (line in commands) {
            val parts = line.split(" ")
            val command = parts[0]
            val argument = parts[1].toInt()

            action(command, argument)
        }
    }

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
}

fun main() {
    val testInput = readInputAsLines("Day02_test")
    check(Day02.part1(testInput) == 150)
    check(Day02.part2(testInput) == 900)

    val input = readInputAsLines("Day02")
    println(Day02.part1(input))
    println(Day02.part2(input))
}
