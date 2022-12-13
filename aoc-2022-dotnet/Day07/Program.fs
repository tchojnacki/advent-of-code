module Day07

open System.IO
open FParsec
open Common

let fileSizeThreshold = 100_000
let totalDiskSpace = 70_000_000
let requiredUnusedSpace = 30_000_000

type Node =
    | File of int // file size
    | Dir of string // dir name

type Command =
    | CD of string // dest
    | LS of Node list // nodes in current dir

let parseCommands =
    let pcd = pstring "$ cd " >>. restOfLine true |>> CD
    let pfile = pint32 .>> pchar ' ' .>> restOfLine true |>> File
    let pdir = pstring "dir " >>. restOfLine true |>> Dir
    let pnode = pfile <|> pdir

    let pls =
        pstring "$ ls" >>. skipNewline >>. many pnode
        |>> LS

    let pcmd = pcd <|> pls
    let pinput = many pcmd

    Util.parse pinput

let combine =
    function
    | (_, "/") -> []
    | (_ :: t, "..") -> t
    | ([], "..") -> failwith "Can't go above root directory!"
    | (path, dest) -> dest :: path

let buildFilesystem commands =
    let rec helper path =
        function
        | (CD dir) :: t -> helper (combine (path, dir)) t
        | (LS list) :: t -> (path, list) :: helper path t
        | [] -> []

    commands |> helper [] |> Map.ofList

let rec dirSize filesystem path =
    filesystem
    |> Map.find path
    |> List.sumBy (function
        | Dir dir -> dirSize filesystem <| combine (path, dir)
        | File size -> size)

let part1 = Seq.filter ((>=) fileSizeThreshold) >> Seq.sum

let part2 sizes =
    let occupiedSpace = Seq.max sizes // root directory size
    let unusedSpace = totalDiskSpace - occupiedSpace
    let missingSpace = requiredUnusedSpace - unusedSpace
    sizes |> Seq.filter ((<=) missingSpace) |> Seq.min

let solution reduceSizes input =
    let filesystem = input |> parseCommands |> buildFilesystem

    filesystem
    |> Map.keys
    |> Seq.map (dirSize filesystem)
    |> reduceSizes

let test = File.ReadAllText("test.txt")
assert (solution part1 test = 95437)
assert (solution part2 test = 24933642)

let input = File.ReadAllText("input.txt")
printfn "%d" <| solution part1 input
printfn "%d" <| solution part2 input
