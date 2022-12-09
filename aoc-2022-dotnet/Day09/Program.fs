module Day09

open System.IO

type Vec2D =
    | Vec2D of int * int
    static member zero = Vec2D(0, 0)
    static member (+)(Vec2D (x1, y1), Vec2D (x2, y2)) = Vec2D(x1 + x2, y1 + y2)
    static member (-)(Vec2D (x1, y1), Vec2D (x2, y2)) = Vec2D(x1 - x2, y1 - y2)
    static member chebyshevDist (Vec2D (x1, y1)) (Vec2D (x2, y2)) = max (abs <| x2 - x1) (abs <| y2 - y1)

let directionToVec =
    Vec2D
    << function
        | 'U' -> (0, 1)
        | 'R' -> (1, 0)
        | 'D' -> (0, -1)
        | 'L' -> (-1, 0)
        | char -> failwithf "Invalid direction: %c" char

let parseHeadMoves =
    Seq.collect (fun (line: string) -> List.replicate (int line[2..]) (directionToVec line[0]))

let constrainTail head tail =
    if Vec2D.chebyshevDist head tail <= 1 then
        tail
    else
        let (Vec2D (dx, dy)) = head - tail
        tail + Vec2D(sign dx, sign dy)

let createRope length = List.replicate length Vec2D.zero

let solution ropeLength =
    parseHeadMoves
    >> Seq.scan
        (fun rope move ->
            match rope with
            | h :: t -> List.scan constrainTail (h + move) t
            | [] -> [])
        (createRope ropeLength)
    >> Seq.map Seq.last
    >> Set
    >> Set.count

let test = File.ReadLines("test.txt")
assert (solution 2 test = 13)
assert (solution 10 test = 1)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution 2 input
printfn "%d" <| solution 10 input
