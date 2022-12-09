module Day01

open System.IO
open FSharpPlus
open Common

let parseLine =
    function
    | "" -> -1
    | l -> int l

let caloriesPerElf = Seq.split [ [ -1 ] ] >> Seq.map Seq.sum

let solution n =
    Seq.map parseLine
    >> caloriesPerElf
    >> Util.topN n
    >> List.sum

let test = File.ReadLines "test.txt"
assert (solution 1 test = 24000)
assert (solution 3 test = 45000)

let input = File.ReadLines "input.txt"
printfn "%d" <| solution 1 input
printfn "%d" <| solution 3 input
