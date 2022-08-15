import java.util.Comparator
import java.util.PriorityQueue
import kotlin.math.absoluteValue
import kotlin.math.max
import kotlin.math.min

object Day23 {
    private enum class Amphipod(val energyPerStep: Int) {
        Amber(1),
        Bronze(10),
        Copper(100),
        Desert(1000);

        companion object {
            fun fromChar(char: Char) = when (char) {
                'A' -> Amber
                'B' -> Bronze
                'C' -> Copper
                'D' -> Desert
                else -> null
            }
        }

        override fun toString(): String {
            return super.toString().first().toString()
        }
    }

    private sealed class Position {
        abstract fun pop(): Position
        abstract fun push(amphipod: Amphipod): Position
        abstract fun peek(): Amphipod

        data class Room(val targetType: Amphipod, val occupants: List<Amphipod>) : Position() {
            override fun pop() = copy(occupants = occupants.dropLast(1))
            override fun push(amphipod: Amphipod) = copy(occupants = occupants + amphipod)
            override fun peek() = occupants.last()
            val isSettled get() = occupants.all { it == targetType }
        }

        data class Hallway(val occupant: Amphipod?) : Position() {
            override fun pop() = copy(occupant = null)
            override fun push(amphipod: Amphipod) = copy(occupant = amphipod)
            override fun peek() = occupant!!
        }
    }

    private data class State(val roomDepth: Int, val positions: List<Position>) {
        companion object {
            fun fromString(input: String) =
                input
                    .split("\n").filter { it.isNotBlank() }.drop(1).dropLast(1)
                    .map { line -> line.drop(1).dropLast(1) }
                    .let { lines ->
                        State(
                            lines.size - 1,
                            (0..10).map { position ->
                                if (lines[1][position] == '#')
                                    Position.Hallway(Amphipod.fromChar(lines.first()[position]))
                                else
                                    Position.Room(
                                        when (position) {
                                            2 -> Amphipod.Amber
                                            4 -> Amphipod.Bronze
                                            6 -> Amphipod.Copper
                                            8 -> Amphipod.Desert
                                            else -> throw IllegalStateException()
                                        },
                                        lines.indices
                                            .drop(1)
                                            .reversed()
                                            .mapNotNull { Amphipod.fromChar(lines[it][position]) }
                                    )
                            }
                        )
                    }
        }

        override fun toString(): String {
            val stringBuilder = StringBuilder()

            stringBuilder.append("#".repeat(positions.size + 2))
            stringBuilder.append('\n')

            stringBuilder.append('#')
            positions.forEach {
                stringBuilder.append(
                    if (it is Position.Hallway) it.occupant?.toString() ?: '.'
                    else '.'
                )
            }
            stringBuilder.append('#')
            stringBuilder.append('\n')

            stringBuilder.append('#')
            positions.forEach {
                stringBuilder.append(
                    if (it is Position.Room) it.occupants.getOrNull(roomDepth - 1)?.toString() ?: '.'
                    else '#'
                )
            }
            stringBuilder.append('#')
            stringBuilder.append('\n')

            val hallwayStart = (positions.indexOfFirst { it is Position.Room } - 1)
            val hallwayEnd = (positions.indexOfLast { it is Position.Room } + 1)
            (roomDepth - 2 downTo 0).forEach { depth ->
                stringBuilder.append(" ".repeat(hallwayStart + 1))
                (hallwayStart..hallwayEnd).map { positions[it] }.forEach {
                    stringBuilder.append(
                        if (it is Position.Room) it.occupants.getOrNull(depth)?.toString() ?: '.'
                        else '#'
                    )
                }
                stringBuilder.append('\n')
            }

            stringBuilder.append(" ".repeat(hallwayStart + 1))
            stringBuilder.append("#".repeat(hallwayEnd - hallwayStart + 1))
            stringBuilder.append('\n')

            return stringBuilder.toString()
        }

        val isFinished
            get() = positions.all {
                when (it) {
                    is Position.Hallway -> hasEmpty(it)
                    is Position.Room -> hasFull(it) && it.occupants.all { a -> a == it.targetType }
                }
            }

        private fun withMove(from: Int, to: Int) = positions[from].peek().let { amphipod ->
            val horizontalDistance = (to - from).absoluteValue
            val outDistance = (positions[from] as? Position.Room)?.let { roomDepth - it.occupants.size + 1 } ?: 0
            val inDistance = (positions[to] as? Position.Room)?.let { roomDepth - it.occupants.size } ?: 0
            val energy = (outDistance + horizontalDistance + inDistance) * amphipod.energyPerStep

            energy to copy(positions = positions.mapIndexed { index, position ->
                when (index) {
                    from -> position.pop()
                    to -> position.push(amphipod)
                    else -> position
                }
            })
        }

        private fun hasHallwayBlocked(from: Int, to: Int) = positions
            .subList(min(from, to) + 1, max(from, to))
            .any { it is Position.Hallway && it.occupant != null }

        private fun hasEmpty(position: Position) = when (position) {
            is Position.Room -> position.occupants.isEmpty()
            is Position.Hallway -> position.occupant == null
        }

        private fun hasFull(position: Position) = when (position) {
            is Position.Room -> position.occupants.size == roomDepth
            is Position.Hallway -> position.occupant != null
        }

        fun allNextStates() = sequence {
            for ((fromPair, toPair) in combinations(positions.withIndex())) {
                val (startIndex, start) = fromPair
                val (endIndex, end) = toPair

                if (
                    startIndex == endIndex ||
                    hasEmpty(start) ||
                    hasFull(end) ||
                    hasHallwayBlocked(startIndex, endIndex)
                )
                    continue

                val afterMove = withMove(startIndex, endIndex)

                when (end) {
                    is Position.Room -> {
                        if (start.peek() == end.targetType && end.isSettled)
                            yield(afterMove)
                    }

                    is Position.Hallway -> {
                        if (start is Position.Room && !start.isSettled)
                            yield(afterMove)
                    }
                }
            }
        }
    }

    private class UniquePriorityQueue<T>(comparator: Comparator<T>) {
        private val internalQueue = PriorityQueue(comparator)
        private val internalSet = mutableSetOf<T>()

        constructor(initialValue: T, comparator: Comparator<T>) : this(comparator) {
            add(initialValue)
        }

        fun add(value: T) {
            if (value !in internalSet) {
                internalQueue.add(value)
                internalSet.add(value)
            }
        }

        fun poll(): T {
            val value = internalQueue.poll()
            internalSet.remove(value)
            return value
        }

        fun isNotEmpty() = internalQueue.isNotEmpty()
    }

    fun part1(input: String): Int {
        val state = State.fromString(input)

        val visited = mutableSetOf<State>()
        val distances = mutableMapOf(state to 0)
        val queue = UniquePriorityQueue(state, compareBy { distances[it]!! })

        queue.add(state)

        while (queue.isNotEmpty()) {
            val current = queue.poll()

            for ((cost, neighbour) in current.allNextStates()) {
                if (neighbour !in visited) {
                    val newCost = distances[current]!! + cost
                    if (newCost < distances.getOrDefault(neighbour, Int.MAX_VALUE)) {
                        distances[neighbour] = newCost
                        queue.add(neighbour)
                    }

                    queue.add(neighbour)
                }
            }

            visited.add(current)
        }

        return distances[visited.find { it.isFinished }]!!
    }

    fun part2(input: String): Int {
        val list = input.split("\n").toMutableList()
        list.addAll(
            3,
            """
            |  #D#C#B#A#
            |  #D#B#A#C#
            """.trimMargin().split("\n")
        )
        return part1(list.joinToString("\n"))
    }
}

fun main() {
    val testInput = """
    #############
    #...........#
    ###B#C#B#D###
      #A#D#C#A#
      #########
    """.trimIndent()
    check(Day23.part1(testInput) == 12521)
    check(Day23.part2(testInput) == 44169)

    val input = """
    #############
    #...........#
    ###D#B#A#C###
      #B#D#A#C#
      #########
    """.trimIndent()
    println(Day23.part1(input))
    println(Day23.part2(input))
}
