import kotlin.collections.ArrayDeque

sealed class Packet(
    private val bits: Int,
    protected val version: Int,
) {
    class Literal(
        bits: Int,
        version: Int,
        private val literalValue: Long,
    ) : Packet(bits, version) {
        override fun versionSum(): Int = version

        override val value: Long
            get() = literalValue
    }

    class Operator(
        bits: Int,
        version: Int,
        private val typeId: Int,
        private val subpackets: List<Packet>,
    ) : Packet(bits, version) {
        override fun versionSum(): Int = version + subpackets.sumOf { it.versionSum() }

        override val value: Long
            get() = when (typeId) {
                0 -> subpackets.sumOf { it.value }
                1 -> subpackets.fold(1) { acc, packet -> acc * packet.value }
                2 -> subpackets.minOf { it.value }
                3 -> subpackets.maxOf { it.value }
                5, 6, 7 -> {
                    val (first, second) = subpackets.map { it.value }

                    if (when (typeId) {
                        5 -> first > second
                        6 -> first < second
                        7 -> first == second
                        else -> false
                    }) {
                        1
                    } else {
                        0
                    }
                }
                else -> throw IllegalStateException("Illegal packet type id.")
            }
    }

    abstract fun versionSum(): Int

    abstract val value: Long

    companion object {
        fun parse(bitQueue: ArrayDeque<Char>): Packet {
            var packetBits = 0

            fun takeBits(n: Int): Int {
                packetBits += n
                return (0 until n)
                    .joinToString("") { bitQueue.removeFirst().toString() }
                    .toInt(2)
            }

            val version = takeBits(3)

            when (val typeId = takeBits(3)) {
                4 -> { // Literal packet
                    var literalValue = 0L
                    while (true) {
                        val groupHeader = takeBits(1)
                        val groupValue = takeBits(4)

                        literalValue = (literalValue shl 4) + groupValue

                        if (groupHeader == 0) {
                            break
                        }
                    }

                    return Literal(packetBits, version, literalValue)
                }
                else -> { // Operator packet
                    val subpackets = mutableListOf<Packet>()

                    when (takeBits(1)) {
                        0 -> {
                            val subpacketLength = takeBits(15)

                            var currentSubpacketLength = 0
                            while (currentSubpacketLength < subpacketLength) {
                                val subpacket = parse(bitQueue)
                                currentSubpacketLength += subpacket.bits
                                subpackets.add(subpacket)
                            }
                        }
                        1 -> {
                            val subpacketCount = takeBits(11)

                            repeat(subpacketCount) {
                                subpackets.add(parse(bitQueue))
                            }
                        }
                        else -> throw IllegalStateException("Illegal length type id.")
                    }

                    packetBits += subpackets.sumOf { it.bits }

                    return Operator(packetBits, version, typeId, subpackets)
                }
            }
        }
    }
}

fun main() {
    fun parse(input: String): Packet {
        val bitQueue = ArrayDeque(
            input
                .flatMap {
                    it
                        .toString()
                        .toInt(16)
                        .toString(2)
                        .padStart(4, '0')
                        .toList()
                }
        )

        return Packet.parse(bitQueue)
    }

    fun part1(input: String): Int = parse(input).versionSum()

    fun part2(input: String): Long = parse(input).value

    check(part1("8A004A801A8002F478") == 16)
    check(part1("620080001611562C8802118E34") == 12)
    check(part1("C0015000016115A2E0802F182340") == 23)
    check(part1("A0016C880162017C3686B18A3D4780") == 31)

    check(part2("C200B40A82") == 3L)
    check(part2("04005AC33890") == 54L)
    check(part2("880086C3E88112") == 7L)
    check(part2("CE00C43D881120") == 9L)
    check(part2("D8005AC2A8F0") == 1L)
    check(part2("F600BC2D8F") == 0L)
    check(part2("9C005AC2F8F0") == 0L)
    check(part2("9C0141080250320F1802104A08") == 1L)


    val input = readInputAsString("Day16")
    println(part1(input))
    println(part2(input))
}
