fun main() {
    fun addLists(l1: List<Int>, l2: List<Int>): List<Int> = l1.zip(l2).map { it.first + it.second }

    fun bitListToNumber(bitList: List<Int>): Int = bitList.reduce { acc, bit -> acc * 2 + bit }

    fun binaryStringToBitList(binaryString: String): List<Int> = binaryString.toList().map { bit -> bit.toString().toInt() }

    fun mostCommonBits(input: List<List<Int>>): List<Int> =
        input
            .reduce(::addLists)
            .map { bit -> if (bit.toDouble() / input.size >= 0.5) { 1 } else { 0 } }

    fun part1(input: List<String>): Int =
        mostCommonBits(input.map(::binaryStringToBitList))
            .let { gammaBits ->
                val epsilonBits = gammaBits.map { bit -> 1 - bit }

                return bitListToNumber(gammaBits) * bitListToNumber(epsilonBits)
            }

    fun part2(input: List<String>): Int {
            var oxygenList = input.map(::binaryStringToBitList)
            var oxygenIdx = 0
            while (oxygenList.size > 1) {
                oxygenList = oxygenList.filter { e -> e[oxygenIdx] == mostCommonBits(oxygenList)[oxygenIdx]}
                oxygenIdx += 1
            }

            var scrubberList = input.map(::binaryStringToBitList)
            var scrubberIdx = 0
            while (scrubberList.size > 1) {
                scrubberList = scrubberList.filter { e -> e[scrubberIdx] != mostCommonBits(scrubberList)[scrubberIdx]}
                scrubberIdx += 1
            }

            return bitListToNumber(oxygenList[0]) * bitListToNumber(scrubberList[0])
        }

    val testInput = readInput("Day03_test")
    check(part1(testInput) == 198)
    check(part2(testInput) == 230)

    val input = readInput("Day03")
    println(part1(input))
    println(part2(input))
}
