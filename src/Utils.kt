import java.io.File
import java.math.BigInteger
import java.security.MessageDigest

/**
 * Reads lines from the given input txt file.
 * @param name name of the file
 * @return list of strings containing line contents
 */
fun readInputAsLines(name: String): List<String> = File("src", "$name.txt").readLines()

/**
 * Read lines from the given input txt file and convert them to decimal numbers.
 * @param name name of the file
 * @return list of ints containing numbers from each of file's lines
 */
fun readInputAsNumbers(name: String): List<Int> = readInputAsLines(name).map { it.toInt() }

/**
 * Read lines from the given input txt file containing binary numbers and convert them to lists of bits.
 * @param name name of the file
 * @return list of lists of ints, where each inner list represents bits of one line of input
 */
fun readInputAsBitLists(name: String): List<List<Int>> =
    readInputAsLines(name)
        .map { binaryString -> binaryString.toList().map { bit -> bit.toString().toInt() } }

/**
 * Converts string to md5 hash.
 * @receiver a string
 * @return md5 hash of receiver
 */
fun String.md5(): String = BigInteger(1, MessageDigest.getInstance("MD5").digest(toByteArray())).toString(16)
