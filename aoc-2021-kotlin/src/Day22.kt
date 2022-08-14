import java.lang.Integer.max
import java.lang.Integer.min

object Day22 {
    private val IntRange.width get() = last - first + 1

    private infix fun IntRange.and(other: IntRange) =
        if (last >= other.first && other.last >= first)
            max(first, other.first)..min(last, other.last)
        else
            null

    data class Cuboid(val x: IntRange, val y: IntRange, val z: IntRange) {
        val volume get() = x.width.toLong() * y.width.toLong() * z.width.toLong()
        val cubes
            get() = sequence {
                x.forEach { xv -> y.forEach { yv -> z.forEach { zv -> yield(Pos3D(xv, yv, zv)) } } }
            }

        infix fun and(other: Cuboid): Cuboid? {
            val x = (x and other.x) ?: return null
            val y = (y and other.y) ?: return null
            val z = (z and other.z) ?: return null
            return Cuboid(x, y, z)
        }

        operator fun contains(pos: Pos3D) = pos.x in x && pos.y in y && pos.z in z
    }

    data class RebootStep(val on: Boolean, val cuboid: Cuboid) {
        companion object {
            fun readSteps(input: List<String>) = input.asSequence().map { line ->
                """(on|off) x=(-?\d+)..(-?\d+),y=(-?\d+)..(-?\d+),z=(-?\d+)..(-?\d+)"""
                    .toRegex()
                    .matchEntire(line)
                    ?.destructured
                    ?.let { (action, minX, maxX, minY, maxY, minZ, maxZ) ->
                        RebootStep(
                            when (action) {
                                "on" -> true
                                "off" -> false
                                else -> throw IllegalArgumentException()
                            },
                            Cuboid(
                                minX.toInt()..maxX.toInt(),
                                minY.toInt()..maxY.toInt(),
                                minZ.toInt()..maxZ.toInt()
                            )
                        )
                    } ?: throw IllegalArgumentException()
            }
        }
    }

    fun part1(input: List<String>) = RebootStep.readSteps(input).toList().let { steps ->
        Cuboid(-50..50, -50..50, -50..50).cubes.sumOf { pos ->
            if (steps.lastOrNull { pos in it.cuboid }?.on == true) 1L else 0L
        }
    }

    fun part2(input: List<String>): Long {
        val counts = mutableMapOf<Cuboid, Int>()

        RebootStep.readSteps(input).forEach { step ->
            val countChanges = mutableMapOf<Cuboid, Int>()

            for (key in counts.keys) {
                val overlap = (step.cuboid and key) ?: continue
                countChanges.putIfAbsent(overlap, 0)
                countChanges.merge(overlap, counts[key]!!, Int::minus)
            }

            if (step.on) countChanges.merge(step.cuboid, 1, Int::plus)

            countChanges.forEach { (key, value) -> counts.merge(key, value, Int::plus) }
        }

        return counts.map { (cuboid, count) -> cuboid.volume * count }.sum()
    }
}

fun main() {
    val testInput = readInputAsLines("Day22_test")
    check(Day22.part1(testInput) == 474140L)
    check(Day22.part2(testInput) == 2758514936282235L)

    val input = readInputAsLines("Day22")
    println(Day22.part1(input))
    println(Day22.part2(input))
}
