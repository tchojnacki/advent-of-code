object Day25 {
    private class SeaCucumbers(private val width: Int, private val height: Int, private val matrix: Array<SeaTile>) {
        companion object {
            fun fromLines(lines: List<String>) =
                Pos2D(
                    lines.getOrNull(0)?.length ?: throw IllegalArgumentException("Sea must have a non-zero height!"),
                    lines.size
                ).let { size ->
                    SeaCucumbers(size.x, size.y, Array(size.x * size.y) {
                        when (val char = lines[it / size.x][it % size.x]) {
                            '>' -> SeaTile.Cucumber.EastFacing
                            'v' -> SeaTile.Cucumber.SouthFacing
                            '.' -> SeaTile.EmptyTile
                            else -> throw IllegalArgumentException("Found '$char', expected '>', 'v' or '.'!")
                        }
                    })
                }
        }

        private sealed class SeaTile {
            object EmptyTile : SeaTile()
            sealed class Cucumber : SeaTile() {
                object EastFacing : Cucumber()
                object SouthFacing : Cucumber()
            }
        }

        private fun moveIndex(index: Int, offset: Pos2D) =
            ((index / width + offset.y) % height) * width + (index + offset.x) % width

        private inline fun <reified T : SeaTile.Cucumber> stepDirection(pos: Pos2D) {
            matrix
                .asSequence()
                .withIndex()
                .map { (index, seaTile) ->
                    val nextIndex = moveIndex(index, pos)
                    if (seaTile is T && matrix[nextIndex] is SeaTile.EmptyTile) {
                        index to nextIndex
                    } else {
                        null
                    }
                }
                .filterNotNull()
                .toList()
                .forEach { (index, nextIndex) ->
                    matrix[nextIndex] = matrix[index].also { matrix[index] = SeaTile.EmptyTile }
                }
        }

        private fun stepOnce() {
            stepDirection<SeaTile.Cucumber.EastFacing>(Pos2D(1, 0))
            stepDirection<SeaTile.Cucumber.SouthFacing>(Pos2D(0, 1))
        }

        fun simulate(): Int {
            var count = 0

            do {
                val previousHashCode = matrix.contentHashCode()
                stepOnce()
                count++
            } while (matrix.contentHashCode() != previousHashCode)

            return count
        }

        override fun toString(): String = matrix
            .withIndex()
            .joinToString("") { (index, seaTile) ->
                when (seaTile) {
                    SeaTile.Cucumber.EastFacing -> ">"
                    SeaTile.Cucumber.SouthFacing -> "v"
                    SeaTile.EmptyTile -> "."
                } + (if (index % width == width - 1) "\n" else "")
            }
    }

    fun singlePart(input: List<String>) = SeaCucumbers.fromLines(input).simulate()
}

fun main() {
    val testInput = readInputAsLines("Day25_test")
    check(Day25.singlePart(testInput) == 58)

    val input = readInputAsLines("Day25")
    println(Day25.singlePart(input))
}
