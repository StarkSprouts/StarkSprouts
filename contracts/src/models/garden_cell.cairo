use starknet::{ContractAddress, get_block_timestamp};
use stark_sprouts::models::plant::{Plant, PlantType, PlantTrait, PlantImpl, Felt252IntoPlantType};
use debug::PrintTrait;

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
    fn plot_status(ref self: GardenCell) -> PlotStatus;
    fn set_has_rock(ref self: GardenCell, has_rock: bool);
    fn toggle_rock(ref self: GardenCell);
    fn plant_seed(ref self: GardenCell, seed_id: u256, cell_index: u16);
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


    /// Set if rock in the garden cell
    fn set_has_rock(ref self: GardenCell, has_rock: bool) {
        self.has_rock = has_rock;
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
                    planted_date: get_block_timestamp(),
                    last_water_date: get_block_timestamp(),
                    last_harvest_date: 0,
                    is_harvestable: false,
                };
    }
}


#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use super::{GardenCell, GradenCellTrait, GardenCellImpl, PlotStatus};
    use stark_sprouts::models::{plant::{Plant, PlantType, PlantImpl, Felt252IntoPlantType},};

    fn setup_garden() -> GardenCell {
        GardenCell {
            player: starknet::contract_address_const::<'player'>(),
            cell_index: 1,
            has_rock: false,
            plant: Plant {
                plant_type: PlantType::None,
                is_dead: false,
                growth_stage: 0,
                water_level: 0,
                planted_date: 0,
                last_water_date: 0,
                last_harvest_date: 0,
                is_harvestable: false,
            },
        }
    }

    #[test]
    #[available_gas(1000000)]
    fn test_set_has_rock() {
        let mut garden_cell = setup_garden();
        assert(!garden_cell.has_rock, 'has_rock should be false');
        garden_cell.set_has_rock(true);
        assert(garden_cell.has_rock, 'has_rock should be true');
        assert(garden_cell.plot_status() == PlotStatus::Rock, 'status should be Rock');
        garden_cell.set_has_rock(false);
        assert(!garden_cell.has_rock, 'has_rock should be false');
        assert(garden_cell.plot_status() == PlotStatus::Empty, 'status should be Empty');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_plant_seed() {
        let mut garden_cell = setup_garden();
        let mut status = garden_cell.plot_status();
        assert(status == PlotStatus::Empty, 'status should be Empty');
        garden_cell.plant_seed(1, 1);
        status = garden_cell.plot_status();
        assert(status == PlotStatus::AlivePlant, 'status should be AlivePlant');
        assert(garden_cell.plant.plant_type == PlantType::Bell, 'plant_type should be Bell');
        garden_cell.plant.water_level = 0;
        garden_cell.plant.update_water_level();
        status = garden_cell.plot_status();
        assert(status == PlotStatus::DeadPlant, 'status should be DeadPlant');
    }
}

