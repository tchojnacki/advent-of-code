namespace Common

type Vec3 =
    | Vec3 of int * int * int

    static member x(Vec3 (x, _, _)) = x
    static member y(Vec3 (_, y, _)) = y
    static member z(Vec3 (_, _, z)) = z

    static member ones = Vec3(1, 1, 1)

    static member directions6 =
        [ Vec3(-1, 0, 0)
          Vec3(1, 0, 0)
          Vec3(0, -1, 0)
          Vec3(0, 1, 0)
          Vec3(0, 0, -1)
          Vec3(0, 0, 1) ]

    static member combine fn (Vec3 (x1, y1, z1)) (Vec3 (x2, y2, z2)) = Vec3(fn x1 x2, fn y1 y2, fn z1 z2)

    static member inline (+)(v1, v2) = Vec3.combine (+) v1 v2
    static member inline (-)(v1, v2) = Vec3.combine (-) v1 v2

    static member neighbours6 v = List.map ((+) v) Vec3.directions6

    static member boundedBy minBound maxBound (Vec3 (x, y, z)) =
        x >= Vec3.x minBound
        && x <= Vec3.x maxBound
        && y >= Vec3.y minBound
        && y <= Vec3.y maxBound
        && z >= Vec3.z minBound
        && z <= Vec3.z maxBound
