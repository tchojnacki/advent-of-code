module Day14

open System.IO
open FParsec
open Common

let sandSpawnPos = Vec2(500, 0)

let sandMoveOffsets =
    [ Vec2.down
      Vec2.downLeft
      Vec2.downRight ]

let notIn set element = not <| Set.contains element set

let buildCaveScan =
    let parsePath =
        let py = pint32 |>> (~-) // mirror Y coordinate
        let ppoint = pint32 .>> (pchar ',') .>>. py |>> Vec2
        let ppath = sepBy ppoint (pstring " -> ")
        Util.parse ppath

    let pathToPositions =
        Seq.pairwise
        >> Seq.collect Vec2.lineBetween
        >> Set

    Seq.map (parsePath >> pathToPositions)
    >> Seq.reduce (+)

let solution1 input =
    let initialCaveScan = buildCaveScan input
    let voidY = initialCaveScan |> Seq.map Vec2.y |> Seq.min

    let settleNewUnit caveScan =
        let rec fall pos =
            if Vec2.y pos <= voidY then
                None
            else
                sandMoveOffsets
                |> Seq.map ((+) pos)
                |> Seq.tryFind (notIn caveScan)
                |> function
                    | Some (nextPos) -> fall nextPos
                    | None -> Some(pos)

        caveScan
        |> match fall sandSpawnPos with
           | Some (settledPos) -> Set.add settledPos
           | None -> id

    initialCaveScan
    |> Seq.unfold (fun caveScan -> Some(caveScan, settleNewUnit caveScan))
    |> Seq.pairwise
    |> Seq.takeWhile (fun (a, b) -> a <> b)
    |> Seq.length

let solution2 input =
    let caveScan = buildCaveScan input
    let floorY = caveScan |> Seq.map Vec2.y |> Seq.min |> (+) -2

    let neighbours pos =
        sandMoveOffsets
        |> List.map ((+) pos)
        |> List.filter (fun pos -> notIn caveScan pos && Vec2.y pos <> floorY)

    let rec dfs stack visited =
        match stack with
        | h :: t -> dfs (List.filter (notIn visited) (neighbours h) @ t) (Set.add h visited)
        | [] -> Set.count visited

    dfs [ sandSpawnPos ] Set.empty

let test = File.ReadLines("test.txt")
assert (solution1 test = 24)
assert (solution2 test = 93)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution1 input
printfn "%d" <| solution2 input
