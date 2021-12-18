import java.lang.IllegalStateException

sealed class FoldCommand {
    abstract fun dispatch(dots: Set<Pos2D>): Set<Pos2D>

    class AlongX(private val x: Int) : FoldCommand() {
        override fun dispatch(dots: Set<Pos2D>): Set<Pos2D> = dots
            .filter { it.x != x }
            .map {
                if (it.x < x) {
                    it
                } else {
                    Pos2D(2 * x - it.x, it.y)
                }
            }
            .toSet()
    }

    class AlongY(val y: Int) : FoldCommand() {
        override fun dispatch(dots: Set<Pos2D>): Set<Pos2D> = dots
            .filter { it.y != y }
            .map {
                if (it.y < y) {
                    it
                } else {
                    Pos2D(it.x, 2 * y - it.y)
                }
            }
            .toSet()
    }
}

fun parseOrigami(input: List<String>): Pair<Set<Pos2D>, Sequence<FoldCommand>> {
    val dots = mutableSetOf<Pos2D>()
    val commands = mutableListOf<FoldCommand>()

    for (line in input) {
        if (line.matches("\\d+,\\d+".toRegex())) {
            val (x, y) = line.split(",").map(String::toInt)
            dots.add(Pos2D(x, y))
        }

        if (line.matches("fold along [xy]=\\d+".toRegex())) {
            val equation = line.substring(11)
            val (axis, valueString) = equation.split("=")
            val value = valueString.toInt()

            commands.add(
                when (axis) {
                    "x" -> FoldCommand.AlongX(value)
                    "y" -> FoldCommand.AlongY(value)
                    else -> throw IllegalStateException("Illegal axis given!")
                }
            )
        }
    }

    return dots to commands.asSequence()
}

fun main() {
    fun part1(input: List<String>): Int {
        val (dots, commands) = parseOrigami(input)

        val res = commands.first().dispatch(dots).size

        return res
    }

    fun part2(input: List<String>): String {
        val origami = parseOrigami(input)
        var dots = origami.first
        val commands = origami.second

        commands.forEach {
            dots = it.dispatch(dots)
        }

        val bounds = dots.reduce { max, pos ->
            when ((pos.x > max.x) to (pos.y > max.y)) {
                true to true -> pos
                true to false -> Pos2D(pos.x, max.y)
                false to true -> Pos2D(max.x, pos.y)
                else -> max
            }
        }

        val lines = Array(bounds.y + 1) { Array(bounds.x + 1) { ' ' } }

        dots.forEach { lines[it.y][it.x] = '#' }

        return lines.joinToString("\n") { it.joinToString("") }
    }


    val testInput = readInputAsLines("Day13_test")
    check(part1(testInput) == 17)

    val input = readInputAsLines("Day13")
    println(part1(input))
    println(part2(input))
}
