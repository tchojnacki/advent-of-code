import kotlin.math.absoluteValue

fun main() {
    fun part1(input: String): Int {
        val numbers = input.trim().split(",").map(String::toInt)
        val range = numbers.minOrNull()!!..numbers.maxOrNull()!!

        return range.minOf { n -> numbers.sumOf { (it - n).absoluteValue } }
    }

    fun part2(input: String): Int {
        val numbers = input.trim().split(",").map(String::toInt)
        val range = numbers.minOrNull()!!..numbers.maxOrNull()!!

        return range.minOf { n -> numbers.map { (it - n).absoluteValue }.sumOf { (it * (it + 1)) / 2 } }
    }

    val testInput = readInputAsString("Day07_test")
    check(part1(testInput) == 37)
    check(part2(testInput) == 168)

    val input = readInputAsString("Day07")
    println(part1(input))
    println(part2(input))
}
