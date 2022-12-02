﻿open System.IO
open FSharpPlus

let parseLine =
    function
    | "" -> -1
    | l -> int l

let caloriesPerElf data =
    data |> Seq.split [ [ -1 ] ] |> Seq.map Seq.sum

let topN n xs =
    let rec insertSorted x =
        function
        | h :: t -> (min h x) :: (insertSorted (max h x) t)
        | _ -> [ x ]

    Seq.fold
        (fun acc elem ->
            if List.length acc < n then
                insertSorted elem acc
            elif List.head acc < elem then
                insertSorted elem (List.tail acc)
            else
                acc)
        List.empty
        xs

let solution n input =
    input
    |> Seq.map parseLine
    |> caloriesPerElf
    |> topN n
    |> List.sum

let test = File.ReadLines "test.txt"
assert (solution 1 test = 24000)
assert (solution 3 test = 45000)

let input = File.ReadLines "input.txt"
printfn "%d" (solution 1 input)
printfn "%d" (solution 3 input)
