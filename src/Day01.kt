fun main() {
    fun part1(input: List<Int>): Int =
        input
            .zipWithNext()
            .count { it.second > it.first }

    fun part2(input: List<Int>): Int =
        input
            .asSequence()
            .windowed(3)
            .map { it.sum() }
            .zipWithNext()
            .count { it.second > it.first }

    val testInput = readInputAsNumbers("Day01_test")
    check(part1(testInput) == 7)
    check(part2(testInput) == 5)

    val input = readInputAsNumbers("Day01")
    println(part1(input))
    println(part2(input))
}
