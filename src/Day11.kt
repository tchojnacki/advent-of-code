fun flashSequence(input: Map<Pos2D, Int>) = sequence {
    val map = input.toMutableMap()

    while (true) {
        val flashed = mutableSetOf<Pos2D>()
        fun canFlash(entry: Map.Entry<Pos2D, Int>): Boolean = entry.value > 9 && !flashed.contains(entry.key)

        // 1)
        map.forEach { (pos, energy) -> map[pos] = energy + 1 }

        // 2)
        while (map.any(::canFlash)) {
            map
                .filter(::canFlash)
                .forEach { (pos, _) ->
                    flashed.add(pos)
                    Pos2D.directions8.map { pos + it }.forEach {
                        if (map.containsKey(it)) {
                            map[it] = map[it]!! + 1
                        }
                    }
                }
        }

        // 3)
        flashed.forEach { map[it] = 0 }

        yield(flashed.size)
    }
}

fun main() {
    fun part1(input: List<String>): Int =
        flashSequence(parseToMap(input))
            .take(100)
            .sum()

    fun part2(input: List<String>): Int =
        flashSequence(parseToMap(input))
            .indexOfFirst { it == 100 } + 1


    val testInput = readInputAsLines("Day11_test")
    check(part1(testInput) == 1656)
    check(part2(testInput) == 195)

    val input = readInputAsLines("Day11")
    println(part1(input))
    println(part2(input))
}
