/**
 * Add two lists element by element.
 * @param l1 first list
 * @param l2 second list
 * @return a new list, where each element at index `i` is equal to `l1.get(i) + l2.get(i)`
 */
fun addLists(l1: List<Int>, l2: List<Int>): List<Int> = l1.zip(l2).map { it.first + it.second }

/**
 * Returns the decimal value of a binary number represented as a list of bits.
 * @param bitList list of bits
 * @return decimal value of binary number
 */
fun valueOfBits(bitList: List<Int>): Int = bitList.reduce { acc, bit -> acc * 2 + bit }

/**
 * Invert all bits of a binary number.
 * @param bitList list of bits
 * @return list of bits, where each bit of [bitList] is flipped
 */
fun invertBits(bitList: List<Int>): List<Int> = bitList.map { bit -> 1 - bit }

/**
 * Given a list of binary numbers (represented as a list of bits) return a binary number,
 * where each bit has the value most common at that position among the numbers in the list.
 * @param input list of lists of bits
 * @return list of bits, where each bit has the most common value in the corresponding position of all numbers in the list
 */
fun mostCommonBits(input: List<List<Int>>): List<Int> =
    input
        .reduce(::addLists)
        .map { bit -> if (bit.toDouble() / input.size >= 0.5) 1 else 0 }

/**
 * Find a binary number from a list, by filtering out values until one remains.
 * While the list has more than one number, remove numbers having a different bit
 * value at current position (starting at 0, increased by 1 after each filtering)
 * then the value at corresponding position in the `comparisonCriteria(currentList)` list.
 * @param input list used to search for the value
 * @param comparisonCriteria function returning a binary number used to compare with others for filtering
 * @return found binary number represented as a list of bits
 */
fun selectByBitCriteria(
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

fun main() {
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

    val testInput = readInputAsBitLists("Day03_test")
    check(part1(testInput) == 198)
    check(part2(testInput) == 230)

    val input = readInputAsBitLists("Day03")
    println(part1(input))
    println(part2(input))
}
