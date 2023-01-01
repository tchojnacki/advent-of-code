module Day19

open System
open System.IO
open System.Text.RegularExpressions

type Resource =
    | Ore
    | Clay
    | Obsidian
    | Geode

    static member list = [ Ore; Clay; Obsidian; Geode ]

type State =
    { Robots: Map<Resource, int>
      Gathered: Map<Resource, int>
      TimeLeft: int }

    static member initial time =
        { Robots =
            Map [ (Ore, 1)
                  (Clay, 0)
                  (Obsidian, 0)
                  (Geode, 0) ]
          Gathered =
            Map [ (Ore, 0)
                  (Clay, 0)
                  (Obsidian, 0)
                  (Geode, 0) ]
          TimeLeft = time }

    member inline state.optimisticGeodeCount =
        state.Gathered[Geode]
        + state.Robots[Geode] * state.TimeLeft
        + state.TimeLeft * (state.TimeLeft - 1) / 2

    static member inline tick state =
        { state with
            Gathered = Map.map (fun resource -> (+) state.Robots[resource]) state.Gathered
            TimeLeft = state.TimeLeft - 1 }

    member inline state.isImpossibleToBuy =
        function
        | Geode -> state.Robots[Obsidian] = 0
        | Obsidian -> state.Robots[Clay] = 0
        | _ -> false

type Blueprint =
    { Id: int
      RobotCosts: Map<Resource, Map<Resource, int>> }

    static member private regex = Regex(@"\d+", RegexOptions.Compiled)

    static member parse input =
        Blueprint.regex.Matches(input)
        |> Seq.map (fun kv -> int kv.Value)
        |> List.ofSeq
        |> function
            | [ id; oreOreCost; clayOreCost; obsidianOreCost; obsidianClayCost; geodeOreCost; geodeObsidianCost ] ->
                { Id = id
                  RobotCosts =
                    Map [ (Ore,
                           Map [ (Ore, oreOreCost)
                                 (Clay, 0)
                                 (Obsidian, 0)
                                 (Geode, 0) ])
                          (Clay,
                           Map [ (Ore, clayOreCost)
                                 (Clay, 0)
                                 (Obsidian, 0)
                                 (Geode, 0) ])
                          (Obsidian,
                           Map [ (Ore, obsidianOreCost)
                                 (Clay, obsidianClayCost)
                                 (Obsidian, 0)
                                 (Geode, 0) ])
                          (Geode,
                           Map [ (Ore, geodeOreCost)
                                 (Clay, 0)
                                 (Obsidian, geodeObsidianCost)
                                 (Geode, 0) ]) ] }
            | _ -> failwith "Invalid blueprint format!"

    member inline private blueprint.canBuyRobot robotResource state =
        Map.forall (fun resource -> (>=) state.Gathered[resource]) blueprint.RobotCosts[robotResource]

    member inline private blueprint.buyRobot robotResource state =
        { state with
            Robots = state.Robots.Change(robotResource, Option.map <| (+) 1)
            Gathered =
                state.Gathered
                |> Map.map (fun costResource previousCount ->
                    previousCount
                    - blueprint.RobotCosts[robotResource][costResource]) }

    static member private robotCaps blueprint =
        Resource.list
        |> List.map (fun costResource ->
            costResource,
            Resource.list
            |> List.map (fun robotResource -> blueprint.RobotCosts[robotResource][costResource])
            |> List.max)
        |> Map.ofList
        |> Map.add Geode Int32.MaxValue

    static member evaluate time blueprint =
        let robotCaps = Blueprint.robotCaps blueprint

        let rec solve bestScore robotGoal state =
            if state.TimeLeft <= 0 then
                state.Gathered[Geode]
            elif state.Robots[robotGoal] >= robotCaps[robotGoal]
                 || state.isImpossibleToBuy robotGoal
                 || state.optimisticGeodeCount <= bestScore then
                bestScore
            elif blueprint.canBuyRobot robotGoal state then
                let state =
                    state
                    |> State.tick
                    |> blueprint.buyRobot robotGoal

                List.fold (fun bestScore nextRobotGoal -> solve bestScore nextRobotGoal state) bestScore Resource.list
            else
                state |> State.tick |> solve bestScore robotGoal

        List.fold (fun bestScore robotGoal -> solve bestScore robotGoal (State.initial time)) 0 Resource.list

    static member inline qualityLevel blueprint =
        blueprint.Id * Blueprint.evaluate 24 blueprint

let solution1 =
    Seq.map Blueprint.parse
    >> Seq.sumBy Blueprint.qualityLevel

let solution2 =
    Seq.map Blueprint.parse
    >> Seq.truncate 3
    >> Seq.map (Blueprint.evaluate 32)
    >> Seq.reduce (*)

let test = File.ReadLines("test.txt")
assert (solution1 test = 33)
assert (solution2 test = 56 * 62)

let input = File.ReadLines("input.txt")
printfn "%d" <| solution1 input
printfn "%d" <| solution2 input
