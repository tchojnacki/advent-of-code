import java.util.*

class CustomPriorityQueue<T>(private val array: Array<T>, private val comparator: Comparator<T>) {
    init {
        array.sortWith(comparator)
    }

    private var i = 0

    private fun indexOfStartingFrom(elem: T, start: Int): Int {
        for (i in (start until array.size)) {
            if (array[i] == elem) {
                return i
            }
        }

        return -1
    }

    fun isNotEmpty(): Boolean = i < array.size

    fun take(): T = array[i++]

    fun revalidate(elem: T) {
        val currentIndex = indexOfStartingFrom(elem, i)

        if (currentIndex == -1) {
            return
        }

        val newIndex = Arrays
            .binarySearch(array, i, currentIndex, elem, comparator)
            .let { if (it >= 0) it else -(it + 1) }

        System.arraycopy(array, newIndex, array, newIndex + 1, currentIndex - newIndex)

        array[newIndex] = elem
    }
}

class Matrix(private val data: Array<IntArray>, private val size: Int) {
    companion object {
        fun fromInput(input: List<String>): Matrix {
            val data = input.map { line ->
                line.map { it.digitToInt() }.toIntArray()
            }.toTypedArray()

            check(data.isNotEmpty()) { "No rows found!" }
            check(data.first().isNotEmpty()) { "No columns found!" }

            return Matrix(data, data.size)
        }
    }

    private fun inMatrix(row: Int, col: Int): Boolean = row in 0 until size && col in 0 until size

    fun set(row: Int, col: Int, value: Int) {
        check(inMatrix(row, col)) { "Invalid position!" }
        data[row][col] = value
    }

    fun get(row: Int, col: Int): Int {
        check(inMatrix(row, col)) { "Invalid position!" }
        return data[row][col]
    }

    fun expand(): Matrix {
        val expandedData = Array(size * 5) { row ->
            IntArray(size * 5) { col ->
                ((data[row % size][col % size] + row / size + col / size) - 1) % 9 + 1
            }
        }

        return Matrix(expandedData, size * 5)
    }

    private fun neighbours(pos: Pair<Int, Int>): Sequence<Pair<Int, Int>> {
        val offsets = sequenceOf(0 to 1, 1 to 0, 0 to -1, -1 to 0)

        return offsets
            .map { pos.first + it.first to pos.second + it.second }
            .filter { it.first in 0 until size && it.second in 0 until size }
    }

    fun dijkstra(): Int {
        val positions = (0 until size)
            .flatMap { row -> (0 until size).map { col -> row to col } }

        val distances =
            positions
                .associateWith { Int.MAX_VALUE }
                .toMutableMap()

        distances[0 to 0] = 0


        val queue = CustomPriorityQueue(positions.toTypedArray(), compareBy { distances[it]!! })

        while (queue.isNotEmpty()) {
            val u = queue.take()

            for (v in neighbours(u)) {
                val newDist = distances[u]!! + data[v.first][v.second]
                if (distances[v]!! > newDist) {
                    distances[v] = newDist
                    queue.revalidate(v)
                }
            }
        }

        return distances[size - 1 to size - 1]!!
    }
}

fun main() {
    fun part1(input: List<String>): Int = Matrix.fromInput(input).dijkstra()

    fun part2(input: List<String>): Int = Matrix.fromInput(input).expand().dijkstra()


    val testInput = readInputAsLines("Day15_test")
    check(part1(testInput) == 40)
    check(part2(testInput) == 315)

    val input = readInputAsLines("Day15")
    println(part1(input))
    println(part2(input))
}
