object Day09 {
    private fun Map<Pos2D, Int>.getLowPoints() =
        filter { (pos, num) -> Pos2D.directions4.all { num < getOrDefault(pos + it, 9) } }

    fun part1(input: List<String>) =
        parseToMap(input).getLowPoints().values.sumOf { it + 1 }

    fun part2(input: List<String>): Int {
        val map = parseToMap(input)

        fun traverseBasin(pos: Pos2D, acc: MutableSet<Pos2D>) {
            acc.add(pos)
            Pos2D.directions4
                .map { pos + it }
                .filter { !acc.contains(it) && map.getOrDefault(it, 9) < 9 }
                .forEach { traverseBasin(it, acc) }
        }

        return map
            .getLowPoints()
            .map {
                val visited = mutableSetOf<Pos2D>()
                traverseBasin(it.key, visited)
                visited.size
            }
            .sortedDescending()
            .take(3)
            .sum()
    }
}

fun main() {
    val testInput = readInputAsLines("Day09_test")
    check(Day09.part1(testInput) == 15)
    check(Day09.part2(testInput) == 1134)

    val input = readInputAsLines("Day09")
    println(Day09.part1(input))
    println(Day09.part2(input))
}
