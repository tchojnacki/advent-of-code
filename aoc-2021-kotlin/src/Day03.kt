object Day03 {
    private fun addLists(l1: List<Int>, l2: List<Int>) = l1.zip(l2).map { it.first + it.second }

    private fun valueOfBits(bitList: List<Int>) = bitList.reduce { acc, bit -> acc * 2 + bit }

    private fun invertBits(bitList: List<Int>) = bitList.map { bit -> 1 - bit }

    private fun mostCommonBits(input: List<List<Int>>): List<Int> =
        input
            .reduce(::addLists)
            .map { bit -> if (bit.toDouble() / input.size >= 0.5) 1 else 0 }

    private fun selectByBitCriteria(
        input: List<List<Int>>,
        comparisonCriteria: (currentList: List<List<Int>>) -> List<Int>
    ): List<Int>? {
        var list = input
        var index = 0

        while (list.size > 1 && index < list[0].size) {
            list = list.filter { e -> e[index] == comparisonCriteria(list)[index] }
            index += 1
        }

        return list.getOrNull(0)
    }

    fun part1(input: List<List<Int>>): Int =
        mostCommonBits(input)
            .let { gammaBits ->
                val epsilonBits = invertBits(gammaBits)
                return valueOfBits(gammaBits) * valueOfBits(epsilonBits)
            }

    fun part2(input: List<List<Int>>): Int {
        val oxygenRating = selectByBitCriteria(input) { mostCommonBits(it) }!!
        val scrubberRating = selectByBitCriteria(input) { invertBits(mostCommonBits(it)) }!!

        return valueOfBits(oxygenRating) * valueOfBits(scrubberRating)
    }
}

fun main() {
    val testInput = readInputAsBitLists("Day03_test")
    check(Day03.part1(testInput) == 198)
    check(Day03.part2(testInput) == 230)

    val input = readInputAsBitLists("Day03")
    println(Day03.part1(input))
    println(Day03.part2(input))
}
