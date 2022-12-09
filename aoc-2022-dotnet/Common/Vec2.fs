namespace Common

type Vec2 =
    | Vec2 of int * int

    static member zero = Vec2(0, 0)

    static member (+)(Vec2 (x1, y1), Vec2 (x2, y2)) = Vec2(x1 + x2, y1 + y2)
    static member (-)(Vec2 (x1, y1), Vec2 (x2, y2)) = Vec2(x1 - x2, y1 - y2)

    static member apply f (Vec2 (x, y)) = Vec2(f x, f y)
    static member sign = Vec2.apply sign
    static member chebyshevDist (Vec2 (x1, y1)) (Vec2 (x2, y2)) = max (abs <| x2 - x1) (abs <| y2 - y1)
