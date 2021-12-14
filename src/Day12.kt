class CaveGraph {
    companion object {
        fun fromLines(input: List<String>): CaveGraph =
            CaveGraph().apply { input.forEach { addConnection(it) } }
    }

    private val adjacencyList = mutableMapOf<Node, Set<Node>>()

    fun addConnection(connectionString: String) {
        val (from, to) = connectionString.split("-").map(Node::fromString)

        adjacencyList.merge(from, setOf(to), Set<Node>::union)
        adjacencyList.merge(to, setOf(from), Set<Node>::union)
    }

    fun countPaths(canUseDoubleTraversal: Boolean = false): Int = traverse(Node.Start, setOf(), !canUseDoubleTraversal)

    private fun traverse(from: Node, visitedBefore: Set<Node>, usedUpDoubleTraverse: Boolean): Int {
        return adjacencyList[from]!!.sumOf {
            when (it) {
                is Node.Start -> 0
                is Node.End -> 1
                is Node.Big -> traverse(it, visitedBefore + from, usedUpDoubleTraverse)
                is Node.Small -> {
                    if (!visitedBefore.contains(it)) {
                        traverse(it, visitedBefore + from, usedUpDoubleTraverse)
                    } else if (!usedUpDoubleTraverse) {
                        traverse(it, visitedBefore + from, true)
                    } else {
                        0
                    }
                }
            }
        }
    }

    sealed class Node {
        companion object {
            fun fromString(text: String): Node = when (text) {
                "start" -> Start
                "end" -> End
                else -> if (text == text.uppercase()) {
                    Big(text)
                } else {
                    Small(text)
                }
            }
        }

        object Start : Node()
        object End : Node()
        data class Small(private val identifier: String) : Node()
        data class Big(private val identifier: String) : Node()
    }
}

fun main() {
    fun part1(input: List<String>): Int = CaveGraph.fromLines(input).countPaths()

    fun part2(input: List<String>): Int = CaveGraph.fromLines(input).countPaths(true)


    val testInput = readInputAsLines("Day12_test")
    check(part1(testInput) == 226)
    check(part2(testInput) == 3509)

    val input = readInputAsLines("Day12")
    println(part1(input))
    println(part2(input))
}
