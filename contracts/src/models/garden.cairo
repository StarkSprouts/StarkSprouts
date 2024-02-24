use starknet::ContractAddress;

#[derive(Model, Drop, Serde)]
struct Garden {
    #[key]
    player: ContractAddress,
    // where are the rocks ? 
    rocks: felt252, // [yes, yes, no, no ...] => 0b...0011 => 3
    // where are the plants ?
    plants: felt252, // [no, no, no, yes, yes, no, no, ...] => 0b...0011000 => 24
    // what type of plant is at each position ?
    plant_types: Array<PlantType>,
}

#[derive(Serde, Copy, Drop, Introspect)]
enum Direction {
    None,
    Left,
    Right,
    Up,
    Down,
}

impl DirectionIntoFelt252 of Into<Direction, felt252> {
    fn into(self: Direction) -> felt252 {
        match self {
            Direction::None => 0,
            Direction::Left => 1,
            Direction::Right => 2,
            Direction::Up => 3,
            Direction::Down => 4,
        }
    }
}

