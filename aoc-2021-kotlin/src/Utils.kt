import java.io.File

fun readInputAsLines(name: String): List<String> = File("aoc-2021-kotlin/src", "$name.txt").readLines()

fun readInputAsString(name: String): String = File("aoc-2021-kotlin/src", "$name.txt").readText()

fun readInputAsNumbers(name: String): List<Int> = readInputAsLines(name).map(String::toInt)

fun readInputAsBitLists(name: String): List<List<Int>> =
    readInputAsLines(name)
        .map { binaryString -> binaryString.toList().map { bit -> bit.toString().toInt() } }

data class Pos2D(val x: Int, val y: Int) {
    companion object {
        val directions4 = listOf(Pos2D(0, 1), Pos2D(1, 0), Pos2D(0, -1), Pos2D(-1, 0))
        val directions8 = directions4 + listOf(
            Pos2D(1, 1),
            Pos2D(1, -1),
            Pos2D(-1, -1),
            Pos2D(-1, 1),
        )
    }

    operator fun plus(other: Pos2D) = Pos2D(x + other.x, y + other.y)

    operator fun minus(other: Pos2D) = Pos2D(x - other.x, y - other.y)
}

fun parseToMap(input: List<String>): Map<Pos2D, Int> =
    input.flatMapIndexed { y, line ->
        line.mapIndexed { x, char ->
            Pos2D(x, y) to char.toString().toInt()
        }
    }.toMap()

fun <T> combinations(first: Iterable<T>, second: Iterable<T> = first): Sequence<Pair<T, T>> =
    sequence {
        first.forEach { a ->
            second.forEach { b ->
                yield(a to b)
            }
        }
    }
