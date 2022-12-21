namespace Common

[<StructuralEquality; StructuralComparison>]
type Vec2 =
    | Vec2 of int * int

    static member x(Vec2 (x, _)) = x
    static member y(Vec2 (_, y)) = y

    static member zero = Vec2(0, 0)
    static member up = Vec2(0, 1)
    static member right = Vec2(1, 0)
    static member down = Vec2(0, -1)
    static member left = Vec2(-1, 0)

    static member upRight = Vec2(1, 1)
    static member upLeft = Vec2(-1, 1)
    static member downLeft = Vec2(-1, -1)
    static member downRight = Vec2(1, -1)

    static member directions4 =
        [ Vec2.up
          Vec2.right
          Vec2.down
          Vec2.left ]

    static member directions8 =
        [ Vec2.up
          Vec2.upRight
          Vec2.right
          Vec2.downRight
          Vec2.down
          Vec2.downLeft
          Vec2.left
          Vec2.upLeft ]

    static member inline (~-) = Vec2.map (~-)
    static member inline (+)(Vec2 (x1, y1), Vec2 (x2, y2)) = Vec2(x1 + x2, y1 + y2)
    static member inline (-)(v1, v2) = v1 + Vec2.op_UnaryNegation (v2)
    static member inline (*)(v1, k) = Vec2.map ((*) k) v1
    static member inline dot (Vec2 (x1, y1)) (Vec2 (x2, y2)) = x1 * x2 + y1 * y2
    static member inline cross (Vec2 (x1, y1)) (Vec2 (x2, y2)) = x1 * y2 - y1 * x2
    static member map f (Vec2 (x, y)) = Vec2(f x, f y)
    static member inline sign = Vec2.map sign
    static member inline lengthSquared(Vec2 (x, y)) = x * x + y * y
    static member mahattanDist (Vec2 (x1, y1)) (Vec2 (x2, y2)) = abs (x2 - x1) + abs (y2 - y1)
    static member chebyshevDist (Vec2 (x1, y1)) (Vec2 (x2, y2)) = max (abs <| x2 - x1) (abs <| y2 - y1)
    static member neighbours4 v = List.map ((+) v) Vec2.directions4
    static member neighbours8 v = List.map ((+) v) Vec2.directions8

    static member lineBetween(Vec2 (x1, y1), Vec2 (x2, y2)) =
        if x1 = x2 then
            seq { min y1 y2 .. max y1 y2 }
            |> Seq.map (fun y -> Vec2(x1, y))
        elif y1 = y2 then
            seq { min x1 x2 .. max x1 x2 }
            |> Seq.map (fun x -> Vec2(x, y1))
        else
            failwith "Points must be in a vertical or horizontal line!"

    static member inMatrix matrix (Vec2 (col, row)) =
        col >= 0
        && col < Array2D.length2 matrix
        && row >= 0
        && row < Array2D.length1 matrix

    static member toIndexOf matrix (Vec2 (col, row)) = (Array2D.length2 matrix) * row + col
