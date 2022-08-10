import kotlin.math.max
import kotlin.math.sign

object Day17 {
    data class Target(val left: Int, val right: Int, val bottom: Int, val top: Int)

    private class Probe(private var vel: Pos2D, private val target: Target) {
        companion object {
            fun search(target: Target): Pair<Int, Int> {
                var highest = 0
                var count = 0

                for (vx in 0..1000) {
                    for (vy in -1000..1000) {
                        val probe = Probe(Pos2D(vx, vy), target)
                        var currentHighest = 0

                        while (probe.canHitTarget) {
                            probe.step()
                            currentHighest = max(currentHighest, probe.pos.y)

                            if (probe.isInTarget) {
                                count++
                                highest = max(highest, currentHighest)
                                break
                            }
                        }
                    }
                }

                return highest to count
            }
        }

        private var pos = Pos2D(0, 0)

        private fun step() {
            pos += vel
            vel = vel.copy(x = vel.x - vel.x.sign, y = vel.y - 1)
        }

        private val canHitTarget
            get() = pos.y > target.bottom

        private val isInTarget
            get() = pos.x in target.left..target.right && pos.y in target.bottom..target.top
    }

    fun bothParts(input: Target) = Probe.search(input)
}

fun main() {
    val testInput = Day17.Target(20, 30, -10, -5)
    val testOutput = Day17.bothParts(testInput)
    check(testOutput.first == 45)
    check(testOutput.second == 112)

    val input = Day17.Target(192, 251, -89, -59)
    val output = Day17.bothParts(input)
    println(output.first)
    println(output.second)
}
