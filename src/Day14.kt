object Day14 {
    private fun getPolymerLetterCounts(input: List<String>, iterations: Int): Long {
        val template = input.first()
        val rules = input.drop(2).associate {
            val (pattern, replacement) = it.split(" -> ")
            (pattern[0] to pattern[1]) to replacement.first()
        }

        var pairCounts = template
            .zipWithNext()
            .groupingBy { it }
            .eachCount()
            .mapValues { (_, v) -> v.toLong() }

        repeat(iterations) {
            val newCounts = mutableMapOf<Pair<Char, Char>, Long>()

            pairCounts.forEach { (pair, count) ->
                newCounts.merge(rules[pair]!! to pair.second, count, Long::plus)
                newCounts.merge(pair.first to rules[pair]!!, count, Long::plus)
            }

            pairCounts = newCounts
        }

        val letterCounts = mutableMapOf<Char, Long>()
        pairCounts.forEach { (pair, count) -> letterCounts.merge(pair.second, count, Long::plus) }
        letterCounts.merge(template.first(), 1, Long::plus)

        return letterCounts.values.let { it.maxOrNull()!! - it.minOrNull()!! }
    }

    fun part1(input: List<String>): Long = getPolymerLetterCounts(input, 10)

    fun part2(input: List<String>): Long = getPolymerLetterCounts(input, 40)
}

fun main() {
    val testInput = readInputAsLines("Day14_test")
    check(Day14.part1(testInput) == 1588L)
    check(Day14.part2(testInput) == 2188189693529L)

    val input = readInputAsLines("Day14")
    println(Day14.part1(input))
    println(Day14.part2(input))
}
