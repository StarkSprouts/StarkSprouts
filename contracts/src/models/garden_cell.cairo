use starknet::ContractAddress;
use stark_sprouts::models::plant::{Plant, PlantType, PlantTrait, PlantImpl};

#[derive(Model, Copy, Drop, Serde)]
struct GardenCell {
    #[key]
    player: ContractAddress,
    #[key]
    cell_index: u16, // 0-224
    has_rock: bool,
    plant: Plant,
}

trait GradenCellTrait {
    fn is_empty(ref self: GardenCell) -> bool;
    fn has_plant(ref self: GardenCell) -> bool;

    fn remove_rock(ref self: GardenCell);
    fn remove_dead_plant(ref self: GardenCell);
    fn plant_seed(ref self: GardenCell, seed_type: u256);
}


impl GardenCellImpl of GradenCellTrait {
    fn is_empty(ref self: GardenCell) -> bool {
        return !self.has_rock && self.plant.plant_type == PlantType::None;
    }

    fn has_plant(ref self: GardenCell) -> bool {
        return self.plant.plant_type != PlantType::None && !self.has_rock;
    }


    fn remove_rock(ref self: GardenCell) {
        self.has_rock = false;
    }

    fn remove_dead_plant(ref self: GardenCell) {
        self.plant.assert_dead();
        self.plant.wipe();
    }

    fn plant_seed(ref self: GardenCell, seed_type: u256) {
        assert(!self.has_rock, 'GardenCell has a rock');
        assert(self.plant.plant_type == PlantType::None, 'Garden cell already has a plant');
    // let plant_type = PlantType::from(seed_types[0]);
    // let plant = Plant { plant_type: plant_type, garden_indexes: garden_indexes, };
    // self.plant = plant;
    // self
    }
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


