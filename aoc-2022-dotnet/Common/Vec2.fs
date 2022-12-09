﻿namespace Common

type Vec2 =
    | Vec2 of int * int

    static member zero = Vec2(0, 0)

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
