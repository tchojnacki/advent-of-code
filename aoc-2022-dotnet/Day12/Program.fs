module Day12

open System.IO
open Common

type Square =
    | Start
    | End
    | Height of char

    static member elevation =
        function
        | Start -> Square.elevation <| Height 'a'
        | End -> Square.elevation <| Height 'z'
        | Height c -> int c - int 'a'

    static member canTraverse a b =
        Square.elevation a + 1 >= Square.elevation b

    static member parse =
        function
        | 'S' -> Start
        | 'E' -> End
        | c when 'a' <= c && c <= 'z' -> Height(c)
        | c -> failwithf "Invalid square: %c" c

type Graph<'T> =
    | Graph of Map<int, 'T * Set<int>>

    static member edges(Graph nodes: Graph<'T>) =
        nodes
        |> Seq.collect (fun kv -> Set.map (fun n -> (kv.Key, n)) (snd kv.Value))
        |> List.ofSeq

    static member withNewEdges (Graph nodes: Graph<'T>) edges =
        nodes
        |> Map.map (fun i (v, _) ->
            (v,
             edges
             |> List.choose (fun (a, b) -> if a = i then Some(b) else None)
             |> Set))
        |> Graph

    static member invert(graph: Graph<'T>) =
        Graph.edges graph
        |> List.map (fun (a, b) -> (b, a))
        |> Graph.withNewEdges graph

    static member distance spred epred (Graph nodes: Graph<'T>) =
        let rec bfsExplore explored =
            function
            | [] -> None
            | (vi, depth) :: queue ->
                (let (v, neighbours) = nodes[vi]

                 if epred v then
                     Some(depth)
                 else
                     bfsExplore
                         (explored + neighbours)
                         (neighbours - explored
                          |> Seq.map (fun n -> (n, depth + 1))
                          |> Seq.append queue
                          |> List.ofSeq))

        let si = Map.findKey (fun _ (v, _) -> spred v) nodes
        bfsExplore (Set.singleton si) [ (si, 0) ]

let solution distanceCalculation =
    array2D
    >> Array2D.map Square.parse
    >> Util.mapEachToSeq (fun matrix pos square ->
        (square,
         Vec2.neighbours4 pos
         |> Set.filter (fun np ->
             Vec2.inMatrix matrix np
             && Square.canTraverse square (Util.mAt matrix np))
         |> Set.map (Vec2.toIndexOf matrix)))
    >> Seq.indexed
    >> Map.ofSeq
    >> Graph
    >> distanceCalculation
    >> Option.get

let part1 = Graph.distance ((=) Start) ((=) End)

let part2 =
    Graph.invert
    >> Graph.distance ((=) End) (Square.elevation >> (=) 0)

let test = File.ReadLines("test.txt")
assert (solution part1 test = 31)
assert (solution part2 test = 29)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution part1 input
printfn "%d" <| solution part2 input
