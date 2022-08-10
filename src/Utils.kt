import java.io.File

/**
 * Reads lines from the given input txt file.
 * @param name name of the file
 * @return list of strings containing line contents
 */
fun readInputAsLines(name: String): List<String> = File("src", "$name.txt").readLines()

/**
 * Returns a string of contents of the given input txt file.
 * @param name name of the file
 * @return contents of file as string
 */
fun readInputAsString(name: String): String = File("src", "$name.txt").readText()

/**
 * Read lines from the given input txt file and convert them to decimal numbers.
 * @param name name of the file
 * @return list of ints containing numbers from each of file's lines
 */
fun readInputAsNumbers(name: String): List<Int> = readInputAsLines(name).map(String::toInt)

/**
 * Read lines from the given input txt file containing binary numbers and convert them to lists of bits.
 * @param name name of the file
 * @return list of lists of ints, where each inner list represents bits of one line of input
 */
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
}

fun parseToMap(input: List<String>): Map<Pos2D, Int> =
    input.flatMapIndexed { y, line ->
        line.mapIndexed { x, char ->
            Pos2D(x, y) to char.toString().toInt()
        }
    }.toMap()
