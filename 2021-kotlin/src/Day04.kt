object Day04 {
    private class Bingo(private val revealQueue: ArrayDeque<Int>, private val boards: List<Board>) {
        companion object {
            fun fromString(input: String): Bingo {
                val sections = input.trim().split("(\\r?\\n){2}".toRegex())

                val revealQueueString = sections.first()
                val revealQueue = ArrayDeque(revealQueueString.split(",").map(String::toInt))

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

        private class Board(private var rows: List<List<Square>>) {
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
                get() = rows.fold(0) { rowAcc, row ->
                    rowAcc + row.fold(0) { squareAcc, square ->
                        squareAcc + if (square is Square.Unmarked) square.number else 0
                    }
                }

            sealed class Square {
                object Marked : Square()
                class Unmarked(val number: Int) : Square()
            }
        }
    }

    fun bothParts(input: String) = Bingo.fromString(input).getResults().let { it.first() to it.last() }
}

fun main() {
    val testInput = readInputAsString("Day04_test")
    val testOutput = Day04.bothParts(testInput)
    check(testOutput.first == 4512)
    check(testOutput.second == 1924)

    val input = readInputAsString("Day04")
    val output = Day04.bothParts(input)
    println(output.first)
    println(output.second)
}
