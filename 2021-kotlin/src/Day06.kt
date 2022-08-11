object Day06 {
    private fun calculateFishPopulation(input: String, days: Int): Long {
        val fishCounts =
            input
                .trim()
                .split(",")
                .map(String::toInt)
                .groupingBy { it }
                .eachCount()
                .mapValues { (_, v) -> v.toLong() }
                .toMutableMap()

        repeat(days) {
            val readyToBirth = fishCounts.getOrDefault(0, 0)
            repeat(8) {
                fishCounts[it] = fishCounts.getOrDefault(it + 1, 0)
            }
            fishCounts.merge(6, readyToBirth, Long::plus)
            fishCounts[8] = readyToBirth
        }

        return fishCounts.values.sum()
    }

    fun part1(input: String): Int = calculateFishPopulation(input, 80).toInt()

    fun part2(input: String): Long = calculateFishPopulation(input, 256)
}

fun main() {
    val testInput = readInputAsString("Day06_test")
    check(Day06.part1(testInput) == 5934)
    check(Day06.part2(testInput) == 26984457539)

    val input = readInputAsString("Day06")
    println(Day06.part1(input))
    println(Day06.part2(input))
}
