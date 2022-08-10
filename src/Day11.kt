object Day11 {
    private fun flashSequence(input: Map<Pos2D, Int>) = sequence {
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

    fun bothParts(input: List<String>) = flashSequence(parseToMap(input)).let { seq ->
        seq.take(100).sum() to seq.indexOfFirst { it == 100 } + 1
    }
}

fun main() {
    val testInput = readInputAsLines("Day11_test")
    val testOutput = Day11.bothParts(testInput)
    check(testOutput.first == 1656)
    check(testOutput.second == 195)

    val input = readInputAsLines("Day11")
    val output = Day11.bothParts(input)
    println(output.first)
    println(output.second)
}
