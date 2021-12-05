import kotlin.math.absoluteValue
import kotlin.math.sign

class Line(val start: Pair<Int, Int>, val end: Pair<Int, Int>) {
    companion object {
        fun fromString(input: String): Line {
            val parts = input.split(" -> ").map { part ->
                val coordinates = part.split(",").map { it.toInt() }
                coordinates[0] to coordinates[1]
            }

            return Line(parts[0], parts[1])
        }
    }
}

fun main() {
    fun part1(input: List<String>): Int {
        val lines = input.map(Line::fromString)

        val positions = mutableMapOf<Pair<Int, Int>, Int>()
        lines.forEach {
            when {
                it.start.first == it.end.first -> {
                    if (it.start.second <= it.end.second) {
                        for (y in it.start.second..it.end.second) {
                            positions[it.start.first to y] = 1 + positions.getOrDefault(it.start.first to y, 0)
                        }
                    } else {
                        for (y in it.end.second..it.start.second) {
                            positions[it.start.first to y] = 1 + positions.getOrDefault(it.start.first to y, 0)
                        }
                    }
                }
                it.start.second == it.end.second -> {
                    if (it.start.first<= it.end.first) {
                        for (x in it.start.first..it.end.first) {
                            positions[x to it.start.second] = 1 + positions.getOrDefault(x to it.start.second, 0)
                        }
                    } else {
                        for (x in it.end.first..it.start.first) {
                            positions[x to it.start.second] = 1 + positions.getOrDefault(x to it.start.second, 0)
                        }
                    }
                }

            }
        }

        return positions.values.count { it >= 2 }
    }


    fun part2(input: List<String>): Int {
        val lines = input.map(Line::fromString)

        val positions = mutableMapOf<Pair<Int, Int>, Int>()
        lines.forEach {
            when {
                it.start.first == it.end.first -> {
                    if (it.start.second <= it.end.second) {
                        for (y in it.start.second..it.end.second) {
                            positions[it.start.first to y] = 1 + positions.getOrDefault(it.start.first to y, 0)
                        }
                    } else {
                        for (y in it.end.second..it.start.second) {
                            positions[it.start.first to y] = 1 + positions.getOrDefault(it.start.first to y, 0)
                        }
                    }
                }
                it.start.second == it.end.second -> {
                    if (it.start.first<= it.end.first) {
                        for (x in it.start.first..it.end.first) {
                            positions[x to it.start.second] = 1 + positions.getOrDefault(x to it.start.second, 0)
                        }
                    } else {
                        for (x in it.end.first..it.start.first) {
                            positions[x to it.start.second] = 1 + positions.getOrDefault(x to it.start.second, 0)
                        }
                    }
                }
                (it.end.first - it.start.first).absoluteValue == (it.end.second - it.start.second).absoluteValue -> {
                    val xOffset = it.end.first - it.start.first
                    val yOffset = it.end.second - it.start.second

                    val xSign = xOffset.sign
                    val ySign = yOffset.sign

                    val length = xOffset.absoluteValue

                    for (i in 0..length) {
                        val x = it.start.first + xSign * i
                        val y = it.start.second + ySign * i
                        positions[x to y] = 1 + positions.getOrDefault(x to y, 0)
                    }

                }
            }
        }

        return positions.values.count { it >= 2 }
    }

    val testInput = readInputAsLines("Day05_test")
    check(part1(testInput) == 5)
    check(part2(testInput) == 12)

    val input = readInputAsLines("Day05")
    println(part1(input))
    println(part2(input))
}
