module Day20

open System.IO
open FSharpPlus.Math.Generic
open Common

let mix listWithIds =
    let cycle = List.length listWithIds - 1

    let move xs idToMove =
        let oldIndex = List.findIndex (fst >> (=) idToMove) xs
        let element = xs[oldIndex]
        let newIndex = int <| remE (int64 oldIndex + snd element) cycle

        xs
        |> List.removeAt oldIndex
        |> List.insertAt newIndex element

    seq { 0..cycle } |> Seq.fold move listWithIds

let nthAfterZero n xs =
    xs
    |> List.item (remE (List.findIndex (snd >> (=) 0L) xs + n) (List.length xs))
    |> snd

let groveCoords multiplier rounds input =
    let mixed =
        input
        |> Seq.map (int64 >> (*) multiplier)
        |> Seq.indexed
        |> List.ofSeq
        |> Util.composition rounds mix

    nthAfterZero 1000 mixed
    + nthAfterZero 2000 mixed
    + nthAfterZero 3000 mixed

let solution1 = groveCoords 1 1
let solution2 = groveCoords 811589153 10

let test = File.ReadLines("test.txt")
assert (solution1 test = 3)
assert (solution2 test = 1623178306)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution1 input
printfn "%d" <| solution2 input
