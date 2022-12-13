module Day09

open System.IO
open Common

let directionToVec =
    function
    | 'U' -> Vec2.up
    | 'R' -> Vec2.right
    | 'D' -> Vec2.down
    | 'L' -> Vec2.left
    | char -> failwithf "Invalid direction: %c" char

let parseHeadMoves =
    Seq.collect (fun (line: string) -> Seq.replicate (int line[2..]) (directionToVec line[0]))

let moveTail head tail =
    if Vec2.chebyshevDist head tail <= 1 then
        tail
    else
        tail + Vec2.sign (head - tail)

let createRope length = List.replicate length Vec2.zero

let solution ropeLength =
    parseHeadMoves
    >> Seq.scan
        (fun rope headMove ->
            match rope with
            | head :: tail -> List.scan moveTail (head + headMove) tail
            | [] -> [])
        (createRope ropeLength)
    >> Seq.map Seq.last
    >> Util.countDistinct

let test = File.ReadLines("test.txt")
assert (solution 2 test = 13)
assert (solution 10 test = 1)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution 2 input
printfn "%d" <| solution 10 input
