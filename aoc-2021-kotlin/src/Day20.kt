object Day20 {
    private class Enhancement private constructor(
        private val algorithm: BooleanArray,
        private val initialImage: Set<Pos2D>
    ) {
        companion object {
            fun fromString(string: String) = string.split("\n\n").let { (algorithm, image) ->
                Enhancement(
                    algorithm.map { it == '#' }.toBooleanArray(),
                    image
                        .split("\n")
                        .withIndex()
                        .flatMap { (y, row) ->
                            row.withIndex().mapNotNull { (x, char) -> if (char == '#') Pos2D(x, y) else null }
                        }
                        .toSet()
                )
            }
        }

        private fun nextStateFor(currentImage: Set<Pos2D>, pos: Pos2D) = combinations(1 downTo -1)
            .map { (dy, dx) -> if (currentImage.contains(pos + Pos2D(dx, dy))) 1 else 0 }
            .withIndex()
            .sumOf { (index, value) -> value shl index }
            .let { algorithm[it] }

        fun enhance(times: Int): Int {
            return generateSequence(StepState.initial(initialImage)) { (image, topLeft, bottomRight) ->
                StepState(
                    combinations(topLeft.y..bottomRight.y, topLeft.x..bottomRight.x)
                        .mapNotNull { (y, x) ->
                            Pos2D(x, y).let { if (nextStateFor(image, it)) it else null }
                        }.toSet(),
                    topLeft + Pos2D(1, 1),
                    bottomRight - Pos2D(1, 1)
                )
            }.drop(times).first().image.size
        }
    }

    private data class StepState(val image: Set<Pos2D>, val topLeft: Pos2D, val bottomRight: Pos2D) {
        companion object {
            fun initial(image: Set<Pos2D>) = StepState(image, Pos2D(-100, -100), Pos2D(200, 200))
        }
    }

    fun part1(input: String) = Enhancement.fromString(input).enhance(2)

    fun part2(input: String) = Enhancement.fromString(input).enhance(50)
}

fun main() {
    val testInput = readInputAsString("Day20_test")
    check(Day20.part1(testInput) == 35)
    check(Day20.part2(testInput) == 3351)

    val input = readInputAsString("Day20")
    println(Day20.part1(input))
    println(Day20.part2(input))
}
