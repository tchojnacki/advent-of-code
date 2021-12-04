class Bingo(private val revealQueue: ArrayDeque<Int>, private val boards: List<Board>) {
    companion object {
        fun fromString(input: String): Bingo {
            val sections = input.trim().split("(\\r?\\n){2}".toRegex())

            val revealQueueString = sections.first()
            val revealQueue = ArrayDeque(revealQueueString.split(",").map { it.toInt() })

            val boards = sections.drop(1).map { Board.fromMatrixString(it) }

            return Bingo(revealQueue, boards)
        }
    }

    fun getResults() = sequence {
        while (revealQueue.isNotEmpty() && boards.any { !it.didWin }) {
            val number = revealQueue.removeFirst()

            for (board in boards.filter { !it.didWin }) {
                board.reveal(number)

                if (board.didWin) {
                    yield(board.sumOfUnmarked * number)
                }
            }
        }
    }

    class Board(private var rows: List<List<Square>>) {
        companion object {
            fun fromMatrixString(matrixString: String): Board = Board(
                matrixString.trim().split("\\r?\\n".toRegex()).map { rowString ->
                    rowString.trim().split("\\s+".toRegex()).map { squareString ->
                        Square.Unmarked(squareString.toInt())
                    }
                }
            )

            private const val SIZE = 5

            private val ROWS = (0 until SIZE).map { row ->
                (0 until SIZE).map { square ->
                    Pair(row, square)
                }
            }

            private val COLUMNS = (0 until SIZE).map { column ->
                (0 until SIZE).map { square ->
                    Pair(square, column)
                }
            }

            private val WINNING_CONFIGURATIONS = ROWS + COLUMNS
        }

        fun reveal(number: Int) {
            rows = rows.map { row ->
                row.map { square ->
                    if (square is Square.Unmarked && square.number == number) Square.Marked else square
                }
            }
        }

        val didWin: Boolean
            get() = WINNING_CONFIGURATIONS.any { configuration ->
                configuration.all { (row, column) -> rows[row][column] is Square.Marked }
            }

        val sumOfUnmarked: Int
            get() = rows.fold(0) { racc, row ->
                racc + row.fold(0) { sacc, square ->
                    sacc + if (square is Square.Unmarked) square.number else 0
                }
            }

        sealed class Square {
            object Marked : Square()
            class Unmarked(val number: Int) : Square()
        }
    }
}

fun main() {
    fun part1(input: String): Int = Bingo.fromString(input).getResults().first()

    fun part2(input: String): Int = Bingo.fromString(input).getResults().last()

    val testInput = readInputAsString("Day04_test")
    check(part1(testInput) == 4512)
    check(part2(testInput) == 1924)

    val input = readInputAsString("Day04")
    println(part1(input))
    println(part2(input))
}
