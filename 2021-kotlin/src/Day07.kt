import kotlin.math.absoluteValue

object Day07 {
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
}

fun main() {
    val testInput = readInputAsString("Day07_test")
    check(Day07.part1(testInput) == 37)
    check(Day07.part2(testInput) == 168)

    val input = readInputAsString("Day07")
    println(Day07.part1(input))
    println(Day07.part2(input))
}
