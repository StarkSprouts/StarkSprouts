use starknet::ContractAddress;
use stark_sprouts::models::plant::{Plant, PlantType, PlantTrait, PlantImpl};

// #[derive(Model, Drop, Serde)]
// struct Garden {
//     #[key]
//     player_address: ContractAddress,
//     cells: [GardenCell; 225],
// }

#[derive(Model, Copy, Drop, Serde)]
struct GardenCell {
    #[key]
    player_address: ContractAddress,
    #[key]
    cell_index: u16, // 0-224
    has_rock: bool,
    plant: Plant,
}

trait GradenCellTrait {
    fn remove_rock(self: GardenCell) -> GardenCell;
    fn plant(self: GardenCell, seed_types: Array<u256>, garden_indexes: Array<u256>) -> GardenCell;
// fn clear_cell(self: GardenCell) -> GardenCell;
}
// #[derive(Serde, Copy, Drop, Introspect)]
// enum Direction {
//     None,
//     Left,
//     Right,
//     Up,
//     Down,
// }

// impl DirectionIntoFelt252 of Into<Direction, felt252> {
//     fn into(self: Direction) -> felt252 {
//         match self {
//             Direction::None => 0,
//             Direction::Left => 1,
//             Direction::Right => 2,
//             Direction::Up => 3,
//             Direction::Down => 4,
//         }
//     }
// }


