fun main() {
    fun part1(input: List<String>): Int {
        var horizontal = 0
        var depth = 0

        for (line in input) {
            val parts = line.split(" ")
            val commandName = parts[0]
            val argument = parts[1].toInt()

            when (commandName) {
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

        for (line in input) {
            val parts = line.split(" ")
            val commandName = parts[0]
            val argument = parts[1].toInt()

            when (commandName) {
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

    val testInput = readInput("Day02_test")
    check(part1(testInput) == 150)
    check(part2(testInput) == 900)

    val input = readInput("Day02")
    println(part1(input))
    println(part2(input))
}
