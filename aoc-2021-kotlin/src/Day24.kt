object Day24 {
    @JvmInline
    private value class Register private constructor(val address: Int) {
        companion object {
            val W = Register(0)
            val X = Register(1)
            val Y = Register(2)
            val Z = Register(3)

            fun fromString(string: String) = when (string) {
                "x" -> X
                "y" -> Y
                "z" -> Z
                "w" -> W
                else -> throw IllegalArgumentException(string)
            }
        }
    }

    private sealed class Instruction {
        companion object {
            fun fromString(string: String) = string.split(" ").let { parts ->
                val operatorString = parts[0]
                val target = Register.fromString(parts[1])

                if (operatorString == "inp") {
                    Input(target)
                } else {
                    val opcode = when (operatorString) {
                        "add" -> Binary.Opcode.ADD
                        "mul" -> Binary.Opcode.MUL
                        "div" -> Binary.Opcode.DIV
                        "mod" -> Binary.Opcode.MOD
                        "eql" -> Binary.Opcode.EQL
                        else -> throw IllegalArgumentException(operatorString)
                    }

                    val source = when (val parsed = parts[2].toLongOrNull()) {
                        is Long -> Source.Literal(parsed)
                        else -> Source.Memory(Register.fromString(parts[2]))
                    }

                    Binary(opcode, target, source)
                }
            }
        }

        data class Input(val register: Register) : Instruction()
        data class Binary(val opcode: Opcode, val a: Register, val b: Source) : Instruction() {
            enum class Opcode {
                ADD, MUL, DIV, MOD, EQL
            }
        }

        sealed class Source {
            data class Memory(val register: Register) : Source()
            data class Literal(val value: Long) : Source()
        }
    }

    private data class ALU(private val memory: LongArray) {
        @Suppress("unused")
        val w get() = memory[Register.W.address]

        @Suppress("unused")
        val x get() = memory[Register.X.address]

        @Suppress("unused")
        val y get() = memory[Register.Y.address]

        @Suppress("unused")
        val z get() = memory[Register.Z.address]

        fun toMutable() = MutableALU(memory.clone())

        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false
            return memory.contentEquals((other as ALU).memory)
        }

        override fun hashCode() = memory.contentHashCode()
    }

    private class MutableALU(private val memory: LongArray) {
        constructor() : this(LongArray(4) { 0L })

        fun toImmutable() = ALU(memory.clone())

        fun executeBatch(batch: List<Instruction.Binary>) {
            batch.forEach {
                memory[it.a.address] = when (it.opcode) {
                    Instruction.Binary.Opcode.ADD -> fetch(it.a) + fetch(it.b)
                    Instruction.Binary.Opcode.MUL -> fetch(it.a) * fetch(it.b)
                    Instruction.Binary.Opcode.DIV -> fetch(it.a) / fetch(it.b)
                    Instruction.Binary.Opcode.MOD -> fetch(it.a) % fetch(it.b)
                    Instruction.Binary.Opcode.EQL -> if (fetch(it.a) == fetch(it.b)) 1L else 0L
                }
            }
        }

        fun feedInput(input: Instruction.Input, value: Long) {
            memory[input.register.address] = value
        }

        private fun fetch(register: Register) = memory[register.address]

        private fun fetch(source: Instruction.Source) = when (source) {
            is Instruction.Source.Literal -> source.value
            is Instruction.Source.Memory -> memory[source.register.address]
        }
    }

    private class Program private constructor(private val parts: List<Part>) {
        companion object {
            fun compileFrom(inputs: List<String>): Program {
                val instructionQueue = inputs.map(Instruction::fromString)

                val parts = mutableListOf<Part>()

                val currentStep = mutableListOf<Instruction.Binary>()
                var currentInput: Instruction.Input? = null

                instructionQueue.forEach {
                    when (it) {
                        is Instruction.Input -> {
                            parts.add(Part(currentInput, currentStep.toList()))

                            currentStep.clear()
                            currentInput = it
                        }

                        is Instruction.Binary -> currentStep.add(it)
                    }
                }

                parts.add(Part(currentInput, currentStep.toList()))

                return Program(parts)
            }
        }

        private data class Part(val input: Instruction.Input?, val instructionBatch: List<Instruction.Binary>)

        private data class Checkpoint(val partNumber: Int, val alu: ALU)

        fun findInputDigits(
            digitRange: IntProgression = 0..9,
            successCondition: (ALU) -> Boolean
        ): Sequence<Long> {
            val cache = mutableSetOf<Checkpoint>()
            val matchingCheckpoints = mutableSetOf<Checkpoint>()

            fun solveRecursively(checkpoint: Checkpoint, accumulator: Long): Sequence<Long> = sequence {
                if (cache.contains(checkpoint)) return@sequence

                if (checkpoint.partNumber == parts.size) {
                    if (successCondition(checkpoint.alu)) {
                        yield(accumulator)
                        val statesOfCurrent = inputStateSequence(accumulator).toSet()
                        matchingCheckpoints.addAll(statesOfCurrent)
                        cache.removeAll(statesOfCurrent)
                    }

                    return@sequence
                }

                digitRange.forEach {
                    yieldAll(
                        solveRecursively(
                            Checkpoint(
                                checkpoint.partNumber + 1,
                                executePart(checkpoint.partNumber, checkpoint.alu, it.toLong()),
                            ),
                            accumulator * 10 + it,
                        )
                    )
                }

                if (!matchingCheckpoints.contains(checkpoint)) cache.add(checkpoint)

                Runtime.getRuntime().let {
                    if (it.totalMemory().toDouble() / it.maxMemory() > 0.75) {
                        cache.clear()
                        it.gc()
                    }
                }
            }

            return solveRecursively(Checkpoint(1, executePart(0)), 0L)
        }

        private fun inputStateSequence(input: Long) = sequence {
            var checkpoint = Checkpoint(1, executePart(0))
            yield(checkpoint)

            input.toString().toCharArray().map { it.toString().toInt() }.forEach {
                checkpoint = Checkpoint(
                    checkpoint.partNumber + 1,
                    executePart(checkpoint.partNumber, checkpoint.alu, it.toLong())
                )
                yield(checkpoint)
            }
        }

        private fun executePart(partNumber: Int, alu: ALU? = null, input: Long? = null): ALU {
            val part = parts[partNumber]
            val executor = alu?.toMutable() ?: MutableALU()

            if (part.input != null && input != null)
                executor.feedInput(part.input, input)

            executor.executeBatch(part.instructionBatch)

            return executor.toImmutable()
        }
    }

    fun bothParts(input: List<String>) = Program
        .compileFrom(input)
        .findInputDigits(digitRange = 9 downTo 1) { it.z == 0L }
        .let { it.first() to it.last() }
}

fun main() {
    val input = readInputAsLines("Day24")
    val output = Day24.bothParts(input)

    println(output.first)
    println(output.second)
}
