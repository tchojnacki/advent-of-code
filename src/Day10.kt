enum class ChunkDelimeter(val open: Char, val close: Char) {
    Parentheses('(', ')'),
    Brackets('[', ']'),
    Braces('{', '}'),
    Angled('<', '>');

    companion object {
        fun isOpening(character: Char): Boolean = values().any { it.open == character }
        fun isClosing(character: Char): Boolean = values().any { it.close == character }
        fun from(character: Char): ChunkDelimeter = values().find { it.open == character || it.close == character }!!
    }
}

sealed class SyntaxError {
    object None : SyntaxError()
    class IncompleteLine(private val stack: ArrayDeque<ChunkDelimeter>) : SyntaxError() {
        val score: Long
            get() {
                fun delimeterValue(delimeter: ChunkDelimeter): Int = when (delimeter) {
                    ChunkDelimeter.Parentheses -> 1
                    ChunkDelimeter.Brackets -> 2
                    ChunkDelimeter.Braces -> 3
                    ChunkDelimeter.Angled -> 4
                }

                return stack.fold(0) { acc, elem -> acc * 5 + delimeterValue(elem) }
            }
    }
    class CorruptedLine(private val invalidDelimeter: ChunkDelimeter) : SyntaxError() {
        val score: Int
            get() = when (invalidDelimeter) {
                ChunkDelimeter.Parentheses -> 3
                ChunkDelimeter.Brackets -> 57
                ChunkDelimeter.Braces -> 1197
                ChunkDelimeter.Angled -> 25137
            }
    }
}

fun parse(line: String): SyntaxError {
    val stack = ArrayDeque<ChunkDelimeter>()

    for (char in line) {
        when {
            ChunkDelimeter.isOpening(char) -> stack.addFirst(ChunkDelimeter.from(char))
            ChunkDelimeter.isClosing(char) -> {
                val closingDelimeter = ChunkDelimeter.from(char)
                if (stack.first() == closingDelimeter) {
                    stack.removeFirst()
                } else {
                    return SyntaxError.CorruptedLine(closingDelimeter)
                }
            }
        }
    }

    if (stack.isNotEmpty()) {
        return SyntaxError.IncompleteLine(stack)
    }

    return SyntaxError.None
}

fun main() {
    fun part1(input: List<String>): Int = input
        .map { parse(it) }
        .filterIsInstance<SyntaxError.CorruptedLine>()
        .sumOf { it.score }
    
    fun part2(input: List<String>): Long =
        input
            .asSequence()
            .map { parse(it) }
            .filterIsInstance<SyntaxError.IncompleteLine>()
            .map { it.score }
            .sorted()
            .toList()
            .let { it[it.size / 2] }


    val testInput = readInputAsLines("Day10_test")
    check(part1(testInput) == 26397)
    check(part2(testInput) == 288957L)

    val input = readInputAsLines("Day10")
    println(part1(input))
    println(part2(input))
}
