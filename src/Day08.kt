object Day08 {
    fun part1(input: List<String>): Int =
        input.sumOf {
            it
                .split("|")[1]
                .trim()
                .split(" ")
                .map(String::length)
                .count { len -> len in listOf(2, 3, 4, 7) }
        }

    fun part2(input: List<String>): Long = input.sumOf { line ->
        val (patternString, outputString) = line.split("|").map(String::trim)
        val patterns = patternString.split(" ").map(String::toSet)

        val one = patterns.first { it.size == 2 }
        val four = patterns.first { it.size == 4 }
        val seven = patterns.first { it.size == 3 }
        val eight = patterns.first { it.size == 7 }

        val top = seven - one
        val middle = patterns.filter { it.size == 5 }.reduce(Set<Char>::intersect) intersect four
        val five = patterns.filter { it.size == 6 }.reduce(Set<Char>::intersect) + middle
        val bottom = five - (four + top)
        val nine = four + top + bottom
        val lowerLeft = eight - nine
        val six = five + lowerLeft
        val lowerRight = one intersect six
        val three = one + top + middle + bottom
        val zero = eight - middle
        val upperLeft = nine - three
        val two = eight - (upperLeft + lowerRight)

        val encodings = listOf(zero, one, two, three, four, five, six, seven, eight, nine)

        outputString
            .split(" ")
            .joinToString("") { encodings.indexOf(it.toSet()).toString() }
            .toLong()
    }
}

fun main() {
    val testInput = readInputAsLines("Day08_test")
    check(Day08.part1(testInput) == 26)
    check(Day08.part2(testInput) == 61229L)

    val input = readInputAsLines("Day08")
    println(Day08.part1(input))
    println(Day08.part2(input))
}
