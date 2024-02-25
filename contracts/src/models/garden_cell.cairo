use starknet::{ContractAddress, get_block_timestamp};
use stark_sprouts::models::plant::{Plant, PlantType, PlantTrait, PlantImpl, Felt252IntoPlantType};

#[derive(Model, Copy, Drop, Serde)]
struct GardenCell {
    #[key]
    player: ContractAddress,
    #[key]
    cell_index: u16, // 0-224
    has_rock: bool,
    plant: Plant,
    creation_date: u64,
}

trait GradenCellTrait {
    fn plot_status(ref self: GardenCell) -> PlotStatus;
    fn remove_rock(ref self: GardenCell);
    fn plant_seed(ref self: GardenCell, seed_id: u256, cell_index: u16);
    fn harvest_seed(ref self: GardenCell);
}

#[derive(PartialEq, Drop)]
enum PlotStatus {
    Empty,
    Rock,
    AlivePlant,
    DeadPlant,
}


impl GardenCellImpl of GradenCellTrait {
    /// Get the status of the GardenCell
    fn plot_status(ref self: GardenCell) -> PlotStatus {
        if self.has_rock {
            return PlotStatus::Rock;
        }

        let plant_type: PlantType = self.plant.plant_type;
        if plant_type == PlantType::None {
            PlotStatus::Empty
        } else if plant_type == PlantType::Dead {
            PlotStatus::DeadPlant
        } else {
            PlotStatus::AlivePlant
        }
    }

    fn remove_rock(ref self: GardenCell) {
        self.has_rock = false;
    }

    fn plant_seed(ref self: GardenCell, seed_id: u256, cell_index: u16) {
        let plant_type = Felt252IntoPlantType::into(seed_id.try_into().unwrap());
        let plant = Plant {
            plant_type,
            growth_stage: 0,
            water_level: 100,
            planted_at: get_block_timestamp(),
            last_watered: get_block_timestamp(),
        };
    // 'GardenCell has a rock');
    // assert(self.plant.plant_type == PlantType::None, 'Garden cell already has a plant');
    // let plant_type = PlantType::from(seed_types[0]);
    // let plant = Plant { plant_type: plant_type, garden_indexes: garden_indexes, };
    // self.plant = plant;
    // self
    }

    fn harvest_seed(
        ref self: GardenCell
    ) { // assert(self.plant.plant_type == PlantType::Dead, 'Garden cell does not have a dead plant');
    // let seed_type = self.plant.plant_type.into();
    // self.plant.reset();
    // seed_type
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


