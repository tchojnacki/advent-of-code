import kotlin.math.absoluteValue
import kotlin.math.max
import kotlin.math.sign

data class Pos(val x: Int, val y: Int)

data class Line(val start: Pos, val end: Pos) {
    companion object {
        fun fromString(input: String): Line {
            val (start, end) = input.split(" -> ").map { coordinateString ->
                val (x, y) = coordinateString.split(",").map(String::toInt)
                Pos(x, y)
            }

            return Line(start, end)
        }
    }

    val isHorizontalOrVertical: Boolean
        get() = start.x == end.x || start.y == end.y

    val isDiagonal: Boolean
        get() = (end.x - start.x).absoluteValue == (end.y - start.y).absoluteValue

    val pointSequence: Sequence<Pos>
        get() = sequence {
            val xOffset = end.x - start.x
            val yOffset = end.y - start.y

            for (s in 0..max(xOffset.absoluteValue, yOffset.absoluteValue)) {
                val x = start.x + s * xOffset.sign
                val y = start.y + s * yOffset.sign

                yield(Pos(x, y))
            }
        }
}

fun main() {
    fun helper(input: List<String>, linePredicate: (line: Line) -> Boolean) = input
        .asSequence()
        .map(Line::fromString)
        .filter(linePredicate)
        .flatMap(Line::pointSequence)
        .groupingBy { it }
        .eachCount()
        .values
        .count { it >= 2 }

    fun part1(input: List<String>): Int = helper(input, Line::isHorizontalOrVertical)

    fun part2(input: List<String>): Int = helper(input) { it.isHorizontalOrVertical || it.isDiagonal }

    val testInput = readInputAsLines("Day05_test")
    check(part1(testInput) == 5)
    check(part2(testInput) == 12)

    val input = readInputAsLines("Day05")
    println(part1(input))
    println(part2(input))
}
