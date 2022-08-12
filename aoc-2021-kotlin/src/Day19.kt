import kotlin.math.absoluteValue

object Day19 {
    private class Scanner private constructor(val beacons: Set<Pos3D>) {
        companion object {
            private const val THRESHOLD = 12

            fun withCenteredBeacon() = Scanner(setOf(Pos3D(0, 0, 0)))

            fun parseScanners(lines: List<String>): List<Scanner> {
                val strippedLines = lines.filter { it.isNotBlank() }

                val groupStartIndices = strippedLines
                    .asSequence()
                    .withIndex()
                    .filter { it.value.startsWith("---") }
                    .map { it.index }
                    .toList()

                return strippedLines
                    .withIndex()
                    .groupBy {
                        groupStartIndices.last { idx -> idx <= it.index }
                    }
                    .values
                    .map { entry ->
                        Scanner(
                            entry
                                .asSequence()
                                .filter { !it.value.startsWith("---") }
                                .map { Pos3D.fromString(it.value) }
                                .toSet()
                        )
                    }
            }

            private fun findOffset(from: Scanner, to: Scanner, axis: (Pos3D) -> Int) =
                to.beacons
                    .flatMap { t -> from.beacons.map { f -> axis(t) - axis(f) } }
                    .toSet()
                    .find { offset ->
                        intersection(
                            from.beacons.map { axis(it) + offset },
                            to.beacons.map(axis)
                        ).size >= THRESHOLD
                    }

            fun findTransform(from: Scanner, to: Scanner): Transform? {
                if (!from.canOverlapWith(to)) return null

                val targetOffsets = uniquePairs(to.beacons)
                    .flatMap { (a, b) -> listOf(a - b, b - a) }

                val rotation = Transform.Rotation.allRotations.find { rotation ->
                    intersection(
                        targetOffsets,
                        uniquePairs(from.withTransform(rotation).beacons).map { (a, b) -> a - b }
                    ).count() >= THRESHOLD * (THRESHOLD - 1) / 2
                } ?: return null

                val rotatedScanner = from.withTransform(rotation)

                val translation = Transform.Translation(
                    Pos3D(
                        findOffset(rotatedScanner, to) { it.x }!!,
                        findOffset(rotatedScanner, to) { it.y }!!,
                        findOffset(rotatedScanner, to) { it.z }!!
                    )
                )

                return rotation + translation
            }
        }

        private fun beaconOffsetIds() = uniquePairs(beacons).map { (a, b) ->
            (b - a).let {
                setOf(
                    it.x.absoluteValue,
                    it.y.absoluteValue,
                    it.z.absoluteValue
                )
            }
        }

        private fun canOverlapWith(other: Scanner) =
            intersection(beaconOffsetIds(), other.beaconOffsetIds())
                .count() >= THRESHOLD * (THRESHOLD - 1) / 2

        fun withTransform(transform: Transform) = Scanner(beacons.map { transform.apply(it) }.toSet())
    }

    private sealed class Transform {
        companion object {
            val identity get() = Composite(listOf())
        }

        abstract fun apply(pos: Pos3D): Pos3D
        abstract fun inverted(): Transform
        protected abstract val list: List<Transform>
        abstract override fun toString(): String

        operator fun plus(other: Transform) = Composite(list + other.list)

        class Translation(private val offset: Pos3D) : Transform() {
            override fun apply(pos: Pos3D) = pos + offset
            override fun inverted() = Translation(-offset)
            override val list get() = listOf(this)
            override fun toString() = offset.let { (x, y, z) -> "T($x,$y,$z)" }
        }

        class Rotation private constructor(private val index: Int) : Transform() {
            companion object {
                val allRotations = (0 until 24).map { Rotation(it) }
            }

            override fun apply(pos: Pos3D) = pos.let { (x, y, z) ->
                listOf(
                    Pos3D(x, y, z), Pos3D(x, z, -y), Pos3D(x, -y, -z), Pos3D(x, -z, y),
                    Pos3D(-x, -y, z), Pos3D(-x, z, y), Pos3D(-x, y, -z), Pos3D(-x, -z, -y),
                    Pos3D(y, z, x), Pos3D(y, x, -z), Pos3D(y, -z, -x), Pos3D(y, -x, z),
                    Pos3D(-y, -z, x), Pos3D(-y, x, z), Pos3D(-y, z, -x), Pos3D(-y, -x, -z),
                    Pos3D(z, x, y), Pos3D(z, y, -x), Pos3D(z, -x, -y), Pos3D(z, -y, x),
                    Pos3D(-z, -x, y), Pos3D(-z, y, x), Pos3D(-z, x, -y), Pos3D(-z, -y, -x)
                )
            }[index]

            override fun inverted() = Pos3D(1, 2, 3).let {
                allRotations.find { inverse ->
                    inverse.apply(this.apply(it)) == it
                }!!
            }

            override val list get() = listOf(this)

            override fun toString() = "R($index)"
        }

        class Composite(private val queue: List<Transform>) : Transform() {
            override fun apply(pos: Pos3D) = queue.fold(pos) { acc, transform -> transform.apply(acc) }
            override fun inverted() = Composite(queue.reversed().map { it.inverted() })
            override val list get() = queue
            override fun toString() = if (list.isEmpty()) "I" else "C(${queue.joinToString("->")})"
        }
    }

    private data class Pos3D(val x: Int, val y: Int, val z: Int) {
        companion object {
            fun fromString(string: String) = string
                .split(",")
                .map(String::toInt)
                .let { Pos3D(it[0], it[1], it[2]) }
        }

        operator fun unaryMinus() = Pos3D(-x, -y, -z)

        operator fun plus(other: Pos3D) = Pos3D(x + other.x, y + other.y, z + other.z)

        operator fun minus(other: Pos3D) = Pos3D(x - other.x, y - other.y, z - other.z)
    }

    private class Graph(private val adjacencyList: List<Set<Edge>>) {
        data class Edge(val destination: Int, val transform: Transform)

        private fun getEdge(from: Int, to: Int) = adjacencyList[from].find { it.destination == to }

        fun findTransformsToZero(): List<Transform> {
            val predecessors = mutableMapOf(0 to 0)
            val queue = mutableListOf(0)

            while (queue.isNotEmpty()) {
                val current = queue.removeFirst()
                for (edge in adjacencyList[current].filter { !predecessors.contains(it.destination) }) {
                    predecessors[edge.destination] = current
                    queue.add(edge.destination)
                }
            }

            return adjacencyList.indices.map { i ->
                generateSequence(i) { if (it == 0) null else predecessors[it] }
                    .zipWithNext()
                    .map { (a, b) -> getEdge(a, b)!!.transform }
                    .fold(Transform.identity) { a, b -> a + b }
            }
        }

        override fun toString() = adjacencyList.withIndex().joinToString("\n") { "${it.index}: ${it.value}" }
    }

    private fun <T> uniquePairs(iterable: Iterable<T>) =
        iterable.withIndex().flatMap {
            iterable.drop(it.index + 1).map { second -> it.value to second }
        }

    private fun <T> intersection(first: Iterable<T>, second: Iterable<T>): List<T> {
        val remaining = first.toMutableList()
        return second.filter { remaining.remove(it) }
    }

    fun bothParts(input: List<String>) = Scanner.parseScanners(input).let { scanners ->
        val edges = uniquePairs(scanners.withIndex())
            .mapNotNull { (a, b) ->
                Scanner.findTransform(a.value, b.value)?.let { a.index to Graph.Edge(b.index, it) }
            }
            .flatMap { listOf(it, it.second.destination to Graph.Edge(it.first, it.second.transform.inverted())) }

        val transforms = Graph(scanners.indices.map { i ->
            edges.asSequence().filter { it.first == i }.map { it.second }.toSet()
        }).findTransformsToZero()

        val firstPart = scanners
            .zip(transforms)
            .map { it.first.withTransform(it.second).beacons }
            .reduce { a, b -> a + b }.size

        val scannerPositions = transforms.map { Scanner.withCenteredBeacon().withTransform(it).beacons.first() }
        val secondPart = uniquePairs(scannerPositions).maxOfOrNull {
            (it.second - it.first).let { (x, y, z) -> x.absoluteValue + y.absoluteValue + z.absoluteValue }
        }

        return@let firstPart to secondPart
    }
}

fun main() {
    val testInput = readInputAsLines("Day19_test")
    val testOutput = Day19.bothParts(testInput)
    check(testOutput.first == 79)
    check(testOutput.second == 3621)

    val input = readInputAsLines("Day19")
    val output = Day19.bothParts(input)
    println(output.first)
    println(output.second)
}
