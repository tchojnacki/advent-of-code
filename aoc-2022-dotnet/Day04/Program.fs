module Day04

open System.IO
open FParsec
open Common

let parseLine =
    let prange = pint32 .>> pstring "-" .>>. pint32
    let ppair = prange .>> pstring "," .>>. prange .>> eof
    Util.parse ppair

let fullyOverlap ((a, b), (c, d)) =
    (a <= c && d <= b) || (c <= a && b <= d)

let overlapAtAll ((a, b), (c, d)) = a <= d && b >= c

let solution predicate =
    Seq.map parseLine >> Util.countWhere predicate

let test = File.ReadLines "test.txt"
assert (solution fullyOverlap test = 2)
assert (solution overlapAtAll test = 4)

let input = File.ReadAllLines "input.txt"
printfn "%d" <| solution fullyOverlap input
printfn "%d" <| solution overlapAtAll input
