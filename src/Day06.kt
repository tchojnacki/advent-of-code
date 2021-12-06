fun main() {
    fun part1(input: String): Int {
        var fish = input.trim().split(",").map(String::toInt)

        repeat(80) {
            val pendingFish = mutableListOf<Int>()

            fish = fish.map {
                when (it) {
                    0 -> {
                        pendingFish.add(8)
                        6
                    }
                    else -> {
                        it - 1
                    }
                }
            } + pendingFish
        }

        return fish.size
    }

    fun part2(input: String): Long {
        val fishCounts =
            input
                .trim()
                .split(",")
                .map(String::toInt)
                .groupingBy { it }
                .eachCount()
                .mapValues { (_, v) -> v.toLong() }
                .toMutableMap()

        repeat(256) {
            val readyToBirth = fishCounts.getOrDefault(0, 0)
            fishCounts[0] = fishCounts.getOrDefault(1, 0)
            fishCounts[1] = fishCounts.getOrDefault(2, 0)
            fishCounts[2] = fishCounts.getOrDefault(3, 0)
            fishCounts[3] = fishCounts.getOrDefault(4, 0)
            fishCounts[4] = fishCounts.getOrDefault(5, 0)
            fishCounts[5] = fishCounts.getOrDefault(6, 0)
            fishCounts[6] = fishCounts.getOrDefault(7, 0) + readyToBirth
            fishCounts[7] = fishCounts.getOrDefault(8, 0)
            fishCounts[8] = readyToBirth
        }

        return fishCounts.values.sum()
    }

    val testInput = readInputAsString("Day06_test")
    check(part1(testInput) == 5934)
    check(part2(testInput) == 26984457539)

    val input = readInputAsString("Day06")
    println(part1(input))
    println(part2(input))
}
