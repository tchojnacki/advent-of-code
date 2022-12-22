module Day18

open System.IO
open FParsec
open Common

let parsePos =
    Util.parse (
        tuple3 (pint32 .>> pchar ',') (pint32 .>> pchar ',') pint32
        |>> Vec3
    )

let fullSurface cubes =
    cubes
    |> Seq.collect Vec3.neighbours6
    |> Seq.filter (Util.notIn cubes)
    |> Seq.length

let externalSurface cubes =
    let hasLava pos = Set.contains pos cubes

    let minBound = Seq.reduce (Vec3.combine min) cubes - Vec3.ones
    let maxBound = Seq.reduce (Vec3.combine max) cubes + Vec3.ones

    let neighbours pos =
        match hasLava pos with
        | true -> []
        | false -> List.filter (Vec3.boundedBy minBound maxBound) (Vec3.neighbours6 pos)

    let rec dfs visited count =
        function
        | pos :: stackTail ->
            let count' = count + if hasLava pos then 1 else 0

            match Set.contains pos visited with
            | true -> dfs visited count' stackTail
            | false -> dfs (Set.add pos visited) count' (neighbours pos @ stackTail)
        | [] -> count

    dfs Set.empty 0 [ minBound ]

let solution surface =
    Seq.map parsePos >> Set.ofSeq >> surface

let test = File.ReadLines("test.txt")
assert (solution fullSurface test = 64)
assert (solution externalSurface test = 2540)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution fullSurface input
printfn "%d" <| solution externalSurface input
