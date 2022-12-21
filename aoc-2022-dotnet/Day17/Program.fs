module Day17

open System.IO
open FSharpPlus
open Common

type Dir =
    | Left
    | Right

    static member movesFromInput(input: string) =
        input
        |> String.trimWhiteSpaces
        |> Seq.map Dir.fromChar
        |> List.ofSeq

    static member private fromChar =
        function
        | '<' -> Left
        | '>' -> Right
        | c -> failwithf "Invalid character: %c" c

    static member shiftOp =
        function
        | Left -> (<<<)
        | Right -> (>>>)

module Row =
    let full = 0b1111111uy
    let empty = 0b0000000uy

    let private countBlocks row =
        let rec helper =
            function
            | 0uy -> 0
            | n -> int (n &&& 1uy) + helper (n >>> 1)

        helper (row &&& full)

    let shift dir shape settled =
        let shape' = (Dir.shiftOp dir) shape 1

        let overflow = countBlocks shape' <> countBlocks shape
        let collision = shape' &&& settled <> empty

        match overflow || collision with
        | true -> None
        | false -> Some(shape')

module Chamber =
    let private shapes =
        [ [ 0b0011110uy ] // horizontal line

          [ 0b0001000uy
            0b0011100uy
            0b0001000uy ] // cross

          [ 0b0000100uy
            0b0000100uy
            0b0011100uy ] // L-shape

          [ 0b0010000uy
            0b0010000uy
            0b0010000uy
            0b0010000uy ] // vertical line

          [ 0b0011000uy; 0b0011000uy ] ] // square

    let private makeSpaceFor shape settled =
        (List.replicate (List.length shape + 3) Row.empty)
        @ settled

    let private shift dir (shape, settled) =
        let shiftedRows = List.map2Shortest (Row.shift dir) shape settled

        let shape =
            shiftedRows
            |> Util.liftList
            |> Option.defaultValue shape

        shape, settled

    let private fall (shape, settled) =
        let (shape', settled') =
            match settled with
            | [ _ ] -> [], shape
            | h :: t when h = Row.empty -> shape, t
            | _ -> Row.empty :: shape, settled

        let collision =
            List.map2Shortest (&&&) shape' settled'
            |> List.exists ((<>) Row.empty)

        if collision then
            [],
            (List.map2Shortest (|||) shape settled)
            @ List.skip (List.length shape) settled
        else
            shape', settled'

    let private stateFingerprint moves shapes tower =
        hash (moves, List.head shapes, List.truncate 128 tower)

    let towerHeight n moves =
        let rec helper (moves, shapes, tower, cache, n) =
            let cacheKey = stateFingerprint moves shapes tower
            let towerHeight = int64 <| List.length tower

            if Map.containsKey cacheKey cache then
                let (oldCount, oldHeight) = cache[cacheKey]
                let countDiff = oldCount - n
                let heightDiff = towerHeight - oldHeight
                let skippedCycles = n / countDiff
                let skippedHeight = skippedCycles * heightDiff
                let leftoverCount = n - skippedCycles * countDiff + 1L

                skippedHeight
                + helper (moves, shapes, tower, Map.empty, leftoverCount)
            else
                let cache = cache |> Map.add cacheKey (n, towerHeight)

                let (shape, shapes) = Util.cycle shapes
                let tower = tower |> makeSpaceFor shape

                let rec step moves shape tower =
                    let (move, moves) = Util.cycle moves
                    let (shape, tower) = shift move (shape, tower)
                    let (shape, tower) = fall (shape, tower)

                    if List.isEmpty shape then
                        (moves, tower)
                    else
                        step moves shape tower

                let (moves, tower) = step moves shape tower

                let n = n - 1L

                if n = 0L then
                    towerHeight
                else
                    helper (moves, shapes, tower, cache, n)

        helper (moves, shapes, [], Map.empty, n)

let solution n =
    Dir.movesFromInput >> Chamber.towerHeight n

let test = File.ReadAllText("test.txt")
assert (solution 2022 test = 3068)
assert (solution 1_000_000_000_000L test = 1514285714288L)

let input = File.ReadAllText("input.txt")
printfn "%d" <| solution 2022 input
printfn "%d" <| solution 1_000_000_000_000L input
