module Day04

open System.IO
open FParsec

let parseLine line =
    let prange = pint32 .>> pstring "-" .>>. pint32
    let ppair = prange .>> pstring "," .>>. prange .>> eof
    Common.parse ppair line

let fullyOverlap ((a, b), (c, d)) =
    (a <= c && d <= b) || (c <= a && b <= d)

let overlapAtAll ((a, b), (c, d)) = a <= d && b >= c

let solution pred =
    Seq.map parseLine >> Seq.filter pred >> Seq.length

let test = File.ReadLines "test.txt"
assert (solution fullyOverlap test = 2)
assert (solution overlapAtAll test = 4)

let input = File.ReadAllLines "input.txt"
printfn "%d" <| solution fullyOverlap input
printfn "%d" <| solution overlapAtAll input
