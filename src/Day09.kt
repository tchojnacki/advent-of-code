fun parseToMap(input: List<String>): Map<Pos2D, Int> =
    input.flatMapIndexed { y, line ->
        line.mapIndexed { x, char ->
            Pos2D(x, y) to char.toString().toInt()
        }
    }.toMap()

fun Map<Pos2D, Int>.getLowPoints(): Map<Pos2D, Int> =
    filter { (pos, num) -> Pos2D.directions.all { num < getOrDefault(pos + it, 9) } }

fun main() {
    fun part1(input: List<String>): Int =
        parseToMap(input).getLowPoints().values.sumOf { it + 1 }

    fun part2(input: List<String>): Int {
        val map = parseToMap(input)

        fun traverseBasin(pos: Pos2D, acc: MutableSet<Pos2D>) {
            acc.add(pos)
            Pos2D.directions
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


    val testInput = readInputAsLines("Day09_test")
    check(part1(testInput) == 15)
    check(part2(testInput) == 1134)

    val input = readInputAsLines("Day09")
    println(part1(input))
    println(part2(input))
}
