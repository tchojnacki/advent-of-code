module Day22

open System.IO
open System.Text.RegularExpressions
open FSharpPlus
open FSharpPlus.Math.Generic
open Common

let passwordRegex = Regex("L|R|\d+", RegexOptions.Compiled)

let facing =
    function
    | Vec2 (1, 0) -> 0
    | Vec2 (0, 1) -> 1
    | Vec2 (-1, 0) -> 2
    | Vec2 (0, -1) -> 3
    | v -> failwithf "Invalid direction: %A" v

let solution wrapper input =
    let map, password = Util.splitStringToTuple "\n\n" input

    let map =
        map
        |> String.split [ "\n" ]
        |> Seq.map (String.padRight 150)
        |> array2D

    let (pos, dir) =
        passwordRegex.Matches(password)
        |> Seq.fold
            (fun (pos, dir) c ->
                match c.Value with
                | "R" -> pos, Vec2.rotateLeft dir
                | "L" -> pos, Vec2.rotateRight dir
                | dist ->
                    Util.composition
                        (int dist)
                        (fun state ->
                            let state' = state |> mapItem1 ((+) <| snd state) |> wrapper

                            match Util.mAt map (fst state') with
                            | '.' -> state'
                            | _ -> state)
                        (pos, dir))
            (Vec2(Seq.findIndex ((=) '.') map[0, *], 0), Vec2.right)

    let (Vec2 (x, y)) = pos + Vec2.ones
    y * 1000 + x * 4 + facing dir

let wrap1 (Vec2 (x, y), d) =
    let x, y =
        match (divE x 50, divE y 50, d) with
        | (1, 3, Vec2 (0, 1))
        | (2, 1, Vec2 (0, 1)) -> x, 0
        | (2, -1, Vec2 (0, -1)) -> x, 49
        | (0, 4, Vec2 (0, 1)) -> x, 100
        | (1, -1, Vec2 (0, -1)) -> x, 149
        | (0, 1, Vec2 (0, -1)) -> x, 199
        | (1, 3, Vec2 (1, 0))
        | (2, 2, Vec2 (1, 0)) -> 0, y
        | (-1, 3, Vec2 (-1, 0)) -> 49, y
        | (2, 1, Vec2 (1, 0))
        | (3, 0, Vec2 (1, 0)) -> 50, y
        | (-1, 2, Vec2 (-1, 0))
        | (0, 1, Vec2 (-1, 0)) -> 99, y
        | (0, 0, Vec2 (-1, 0)) -> 149, y
        | _ -> x, y

    Vec2(x, y), d

let wrap2 (Vec2 (x, y), d) =
    let x, y, t =
        match (divE x 50, divE y 50, d) with
        | (-1, 2, Vec2 (-1, 0)) -> 50, 149 - y, Vec2.flip
        | (-1, 3, Vec2 (-1, 0)) -> y - 100, 0, Vec2.rotateRight
        | (0, 0, Vec2 (-1, 0)) -> 0, 149 - y, Vec2.flip
        | (0, 1, Vec2 (-1, 0)) -> y - 50, 100, Vec2.rotateRight
        | (0, 1, Vec2 (0, -1)) -> 50, x + 50, Vec2.rotateLeft
        | (0, 4, Vec2 (0, 1)) -> x + 100, 0, id
        | (1, -1, Vec2 (0, -1)) -> 0, x + 100, Vec2.rotateLeft
        | (1, 3, Vec2 (1, 0)) -> y - 100, 149, Vec2.rotateRight
        | (1, 3, Vec2 (0, 1)) -> 49, x + 100, Vec2.rotateLeft
        | (2, -1, Vec2 (0, -1)) -> x - 100, 199, id
        | (2, 1, Vec2 (1, 0)) -> y + 50, 49, Vec2.rotateRight
        | (2, 1, Vec2 (0, 1)) -> 99, x - 50, Vec2.rotateLeft
        | (2, 2, Vec2 (1, 0)) -> 149, 149 - y, Vec2.flip
        | (3, 0, Vec2 (1, 0)) -> 99, 149 - y, Vec2.flip
        | _ -> x, y, id

    Vec2(x, y), t d

let input = File.ReadAllText("input.txt")
printfn "%b" (solution wrap1 input = 103224)
printfn "%b" (solution wrap2 input = 189097)
