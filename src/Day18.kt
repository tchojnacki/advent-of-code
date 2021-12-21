import kotlin.math.ceil
import kotlin.math.floor

class SnailfishNum private constructor(private val data: MutableList<Entry>) {
    data class Entry(var num: Int, val depth: Int)

    companion object {
        fun parse(input: String): SnailfishNum {
            var depth = 0
            val list = mutableListOf<Entry>()

            for (char in input) {
                when (char) {
                    '[' -> depth += 1
                    ']' -> depth -= 1
                    ',' -> {}
                    else -> list.add(Entry(char.toString().toInt(), depth))
                }
            }

            return SnailfishNum(list)
        }
    }

    private val shouldExplode
        get() = data
            .zipWithNext()
            .any { it.first.depth == it.second.depth && it.first.depth >= 5 }

    private val shouldSplit
        get() = data.any { it.num >= 10 }

    private fun explode() {
        val (leftIndex, rightIndex) = data
            .zipWithNext()
            .indexOfFirst { it.first.depth == it.second.depth && it.first.depth >= 5 }
            .let { it to it + 1 }

        if (leftIndex - 1 in data.indices) {
            data[leftIndex - 1].num += data[leftIndex].num
        }

        if (rightIndex + 1 in data.indices) {
            data[rightIndex + 1].num += data[rightIndex].num
        }

        data[leftIndex] = Entry(0, data[leftIndex].depth - 1)
        data.removeAt(rightIndex)
    }

    private fun split() {
        val index = data.indexOfFirst { it.num >= 10 }
        val depth = data[index].depth

        val half = data[index].num / 2.0
        val roundedDown = floor(half).toInt()
        val roundedUp = ceil(half).toInt()

        data[index] = Entry(roundedUp, depth + 1)
        data.add(index, Entry(roundedDown, depth + 1))
    }

    private fun reduce() {
        while (true) {
            if (shouldExplode) {
                explode()
            } else if (shouldSplit) {
                split()
            } else {
                break
            }
        }
    }

    fun magnitude(): Int {
        val dataCopy = data.toMutableList()

        while (dataCopy.size > 1) {
            val maxDepth = dataCopy.maxOf { it.depth }

            val (leftIndex, rightIndex) = dataCopy
                .zipWithNext()
                .indexOfFirst { it.first.depth == it.second.depth && it.first.depth == maxDepth }
                .let { it to it + 1 }

            dataCopy[leftIndex] = Entry(
                dataCopy[leftIndex].num * 3 + dataCopy[rightIndex].num * 2,
                maxDepth - 1
            )
            dataCopy.removeAt(rightIndex)
        }

        return dataCopy.first().num
    }

    operator fun plus(other: SnailfishNum): SnailfishNum =
        SnailfishNum(
            (this.data + other.data).map { Entry(it.num, it.depth + 1) }.toMutableList()
        ).also { it.reduce() }
}

fun <T> combinations(items: Sequence<T>): Sequence<Pair<T, T>> =
    sequence {
        items.forEach { a ->
            items.forEach { b ->
                yield(a to b)
            }
        }
    }

fun main() {
    fun part1(input: List<String>): Int =
        input
            .asSequence()
            .map(SnailfishNum::parse)
            .reduce(SnailfishNum::plus)
            .magnitude()

    fun part2(input: List<String>): Int =
        combinations(
            input
                .asSequence()
                .map(SnailfishNum::parse)
        )
            .filter { it.first !== it.second }
            .maxOf { (it.first + it.second).magnitude() }


    val testInput = readInputAsLines("Day18_test")
    check(part1(testInput) == 4140)
    check(part2(testInput) == 3993)

    val input = readInputAsLines("Day18")
    println(part1(input))
    println(part2(input))
}
