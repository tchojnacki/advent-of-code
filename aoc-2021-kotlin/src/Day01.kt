object Day01 {
    fun part1(input: List<Int>) =
        input
            .zipWithNext()
            .count { it.second > it.first }

    fun part2(input: List<Int>) =
        input
            .asSequence()
            .windowed(3)
            .map { it.sum() }
            .zipWithNext()
            .count { it.second > it.first }
}

fun main() {
    val testInput = readInputAsNumbers("Day01_test")
    check(Day01.part1(testInput) == 7)
    check(Day01.part2(testInput) == 5)

    val input = readInputAsNumbers("Day01")
    println(Day01.part1(input))
    println(Day01.part2(input))
}
