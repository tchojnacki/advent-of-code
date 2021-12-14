fun getPolymerLetterCounts(input: List<String>, iterations: Int): Long {
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

fun main() {
    fun part1(input: List<String>): Long = getPolymerLetterCounts(input, 10)

    fun part2(input: List<String>): Long = getPolymerLetterCounts(input, 40)


    val testInput = readInputAsLines("Day14_test")
    check(part1(testInput) == 1588L)
    check(part2(testInput) == 2188189693529L)

    val input = readInputAsLines("Day14")
    println(part1(input))
    println(part2(input))
}
