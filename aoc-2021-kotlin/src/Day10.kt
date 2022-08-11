object Day10 {
    private enum class ChunkDelimiter(val open: Char, val close: Char) {
        Parentheses('(', ')'),
        Brackets('[', ']'),
        Braces('{', '}'),
        Angled('<', '>');

        companion object {
            fun isOpening(character: Char): Boolean = values().any { it.open == character }
            fun isClosing(character: Char): Boolean = values().any { it.close == character }
            fun from(character: Char): ChunkDelimiter =
                values().find { it.open == character || it.close == character }!!
        }
    }

    private sealed class SyntaxError {
        object None : SyntaxError()
        class IncompleteLine(private val stack: ArrayDeque<ChunkDelimiter>) : SyntaxError() {
            val score: Long
                get() {
                    fun delimiterValue(delimiter: ChunkDelimiter): Int = when (delimiter) {
                        ChunkDelimiter.Parentheses -> 1
                        ChunkDelimiter.Brackets -> 2
                        ChunkDelimiter.Braces -> 3
                        ChunkDelimiter.Angled -> 4
                    }

                    return stack.fold(0) { acc, elem -> acc * 5 + delimiterValue(elem) }
                }
        }

        class CorruptedLine(private val invalidDelimiter: ChunkDelimiter) : SyntaxError() {
            val score: Int
                get() = when (invalidDelimiter) {
                    ChunkDelimiter.Parentheses -> 3
                    ChunkDelimiter.Brackets -> 57
                    ChunkDelimiter.Braces -> 1197
                    ChunkDelimiter.Angled -> 25137
                }
        }
    }

    private fun parse(line: String): SyntaxError {
        val stack = ArrayDeque<ChunkDelimiter>()

        for (char in line) {
            when {
                ChunkDelimiter.isOpening(char) -> stack.addFirst(ChunkDelimiter.from(char))
                ChunkDelimiter.isClosing(char) -> {
                    val closingDelimiter = ChunkDelimiter.from(char)
                    if (stack.first() == closingDelimiter) {
                        stack.removeFirst()
                    } else {
                        return SyntaxError.CorruptedLine(closingDelimiter)
                    }
                }
            }
        }

        if (stack.isNotEmpty()) {
            return SyntaxError.IncompleteLine(stack)
        }

        return SyntaxError.None
    }

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
}

fun main() {
    val testInput = readInputAsLines("Day10_test")
    check(Day10.part1(testInput) == 26397)
    check(Day10.part2(testInput) == 288957L)

    val input = readInputAsLines("Day10")
    println(Day10.part1(input))
    println(Day10.part2(input))
}
