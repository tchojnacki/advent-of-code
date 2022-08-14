import java.lang.Long.max

object Day21 {
    private class Dice {
        private var nextRoll = 1

        var rollCount = 0
            private set

        private fun roll(): Int {
            rollCount++
            return nextRoll.also { nextRoll = nextRoll % 100 + 1 }
        }

        fun rollThrice() = roll() + roll() + roll()
    }

    fun part1(firstPosition: Int, secondPosition: Int): Int {
        val dice = Dice()
        val playerPositions = mutableListOf(firstPosition, secondPosition)
        val playerScores = mutableListOf(0, 0)
        var nextPlayer = 0

        while (playerScores.none { it >= 1000 }) {
            playerPositions[nextPlayer] = wrapPosition(playerPositions[nextPlayer] + dice.rollThrice())
            playerScores[nextPlayer] += playerPositions[nextPlayer]
            nextPlayer = 1 - nextPlayer
        }

        return playerScores[nextPlayer] * dice.rollCount
    }

    private val tripleRollSumFrequencies = sequence {
        (1..3).let { range ->
            range.forEach { a ->
                range.forEach { b ->
                    range.forEach { c ->
                        yield(a + b + c)
                    }
                }
            }
        }
    }.groupingBy { it }.eachCount()

    private fun wrapPosition(position: Int) = (position - 1).mod(10) + 1

    private data class RecursionInput(val endingPos: Int, val score: Int, val turns: Int, val initialPos: Int)

    private val universeSolutionCache = mutableMapOf<RecursionInput, Long>()

    private fun universeCount(i: RecursionInput): Long {
        universeSolutionCache[i]?.let { return it }

        if (i.score !in 0 until 21 + i.endingPos) return 0

        if (i.turns == 0) return (if (i.score == 0 && i.endingPos == i.initialPos) 1L else 0L)

        return tripleRollSumFrequencies.map { (rolledSum, occurrences) ->
            occurrences * universeCount(
                RecursionInput(
                    wrapPosition(i.endingPos - rolledSum),
                    i.score - i.endingPos,
                    i.turns - 1,
                    i.initialPos
                )
            )
        }.sum().also { universeSolutionCache[i] = it }
    }

    private fun countWinningUniverses(winnerInitialPos: Int, loserInitialPos: Int, isSecondWinner: Boolean) =
        combinations(1..10).sumOf { (winnerEndPos, loserEndPos) ->
            combinations(21..30, 0..20).sumOf { (winnerScore, loserScore) ->
                (0..10).sumOf { turns ->
                    universeCount(
                        RecursionInput(
                            winnerEndPos,
                            winnerScore,
                            turns,
                            winnerInitialPos
                        )
                    ) * universeCount(
                        RecursionInput(
                            loserEndPos,
                            loserScore,
                            if (isSecondWinner) turns else turns - 1,
                            loserInitialPos
                        )
                    )
                }
            }
        }

    fun part2(firstPosition: Int, secondPosition: Int) = max(
        countWinningUniverses(firstPosition, secondPosition, false),
        countWinningUniverses(secondPosition, firstPosition, true)
    )
}

fun main() {
    check(Day21.part1(4, 8) == 739785)
    check(Day21.part2(4, 8) == 444356092776315)

    println(Day21.part1(2, 7))
    println(Day21.part2(2, 7))
}
