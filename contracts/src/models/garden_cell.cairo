use starknet::{ContractAddress, get_block_timestamp};
use stark_sprouts::models::plant::{Plant, PlantType, PlantTrait, PlantImpl, Felt252IntoPlantType};

#[derive(Model, Copy, Drop, Serde)]
struct GardenCell {
    #[key]
    player: ContractAddress,
    #[key]
    cell_index: u16, // 0-224
    has_rock: bool, // discussed enum here, but instead going to move to player stats, that way two rocsk cannot be removed at the same time
    plant: Plant,
}

trait GradenCellTrait {
    fn plot_status(ref self: GardenCell) -> PlotStatus;
    fn toggle_rock(ref self: GardenCell);
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
    /// Get the status of the garden cell
    fn plot_status(ref self: GardenCell) -> PlotStatus {
        if self.has_rock {
            PlotStatus::Rock
        } else if self.plant.is_dead {
            PlotStatus::DeadPlant
        } else if self.plant.plant_type == PlantType::None {
            PlotStatus::Empty
        } else {
            PlotStatus::AlivePlant
        }
    }

    /// Toggle if rock in the garden cell
    fn toggle_rock(ref self: GardenCell) {
        self.has_rock = !self.has_rock;
    }


    fn plant_seed(ref self: GardenCell, seed_id: u256, cell_index: u16) {
        let plant_type = Felt252IntoPlantType::into(seed_id.try_into().unwrap());
        self
            .plant =
                Plant {
                    plant_type,
                    is_dead: false,
                    growth_stage: 0,
                    water_level: 100,
                    planted_at: get_block_timestamp(),
                    last_water_date: get_block_timestamp(),
                    last_harvest_date: 0,
                    is_harvestable: false,
                };
    }

    fn harvest_seed(
        ref self: GardenCell
    ) { // assert(self.plant.plant_type == PlantType::Dead, 'Garden cell does not have a dead plant');
    // let seed_type = self.plant.plant_type.into();
    // self.plant.reset();
    // seed_type
    }
}


#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use super::{GardenCell, GradenCellTrait, GardenCellImpl, PlotStatus};

    fn setup_garden() {}
}

