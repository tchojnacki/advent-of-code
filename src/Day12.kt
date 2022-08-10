object Day12 {
    private class CaveGraph {
        companion object {
            fun fromLines(input: List<String>): CaveGraph =
                CaveGraph().apply { input.forEach { addConnection(it) } }
        }

        private val adjacencyList = mutableMapOf<Node, Set<Node>>()

        private fun addConnection(connectionString: String) {
            val (from, to) = connectionString.split("-").map(Node::fromString)

            adjacencyList.merge(from, setOf(to), Set<Node>::union)
            adjacencyList.merge(to, setOf(from), Set<Node>::union)
        }

        fun countPaths(canUseDoubleTraversal: Boolean = false): Int =
            traverse(Node.Start, setOf(), !canUseDoubleTraversal)

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

        private sealed class Node {
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

    fun bothParts(input: List<String>) = CaveGraph.fromLines(input).let { it.countPaths() to it.countPaths(true) }
}

fun main() {
    val testInput = readInputAsLines("Day12_test")
    val testOutput = Day12.bothParts(testInput)
    check(testOutput.first == 226)
    check(testOutput.second == 3509)

    val input = readInputAsLines("Day12")
    val output = Day12.bothParts(input)
    println(output.first)
    println(output.second)
}
