import java.io.File
import java.math.BigInteger
import java.security.MessageDigest

/**
 * Reads lines from the given input txt file.
 */
fun readInputAsLines(name: String): List<String> = File("src", "$name.txt").readLines()

fun readInputAsNumbers(name: String): List<Int> = readInputAsLines(name).map { it.toInt() }

fun readInputAsBitLists(name: String): List<List<Int>> =
    readInputAsLines(name)
        .map { binaryString -> binaryString.toList().map { bit -> bit.toString().toInt() } }

/**
 * Converts string to md5 hash.
 */
fun String.md5(): String = BigInteger(1, MessageDigest.getInstance("MD5").digest(toByteArray())).toString(16)
