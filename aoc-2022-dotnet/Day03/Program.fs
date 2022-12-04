﻿module Day03

open System.IO

let priority item =
    if 'a' <= item && item <= 'z' then
        int item - int 'a' + 1
    elif 'A' <= item && item <= 'Z' then
        int item - int 'A' + 27
    else
        failwithf "Invalid item: %c" item

let cutInHalf xs =
    let half = Seq.length xs / 2
    [ Seq.take half xs; Seq.skip half xs ]

let solution1 =
    Seq.sumBy (
        cutInHalf
        >> Seq.map Set
        >> Set.intersectMany
        >> Seq.exactlyOne
        >> priority
    )

let solution2 =
    Seq.chunkBySize 3
    >> Seq.sumBy (
        Seq.map Set
        >> Set.intersectMany
        >> Seq.exactlyOne
        >> priority
    )

let test = File.ReadLines "test.txt"
assert (solution1 test = 157)
assert (solution2 test = 70)

let input = File.ReadAllLines "input.txt"
printfn "%d" <| solution1 input
printfn "%d" <| solution2 input
