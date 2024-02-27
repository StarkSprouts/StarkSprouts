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
    /// Get the status of the garden cell
    fn plot_status(ref self: GardenCell) -> PlotStatus;
    /// Plant a seed in the garden cell
    fn plant_seed(ref self: GardenCell, seed_id: u256, cell_index: u16);
    /// Set if there is a rock in plot or not
    fn set_has_rock(ref self: GardenCell, has_rock: bool);
}

/// The status of the garden cell
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

    /// Plant a seed in the garden cell
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
                    last_water_date: starknet::get_block_timestamp(),
                    last_harvest_date: 0,
                    is_harvestable: false,
                };
    }

    /// Set if there is a rock in the plot or not
    fn set_has_rock(ref self: GardenCell, has_rock: bool) {
        self.has_rock = has_rock;
    }
}

#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use super::{GardenCell, GradenCellTrait, GardenCellImpl, PlotStatus};
    use stark_sprouts::models::{plant::{Plant, PlantType, PlantImpl, Felt252IntoPlantType},};

    /// Makes an empty garden cell
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

    /// Tests plot status 
    /// @dev Tests plant_seed & set_has_rock indirectly
    fn test_plot_status() {
        let mut garden_cell = setup_garden();
        let status = garden_cell.plot_status();
        assert(status == PlotStatus::Empty, 'status should be Empty');
        garden_cell.set_has_rock(true);
        let status = garden_cell.plot_status();
        assert(status == PlotStatus::Rock, 'status should be Rock');
        garden_cell.set_has_rock(false);
        let status = garden_cell.plot_status();
        assert(status == PlotStatus::Empty, 'status should be Empty');
        garden_cell.plant_seed(1, 1);
        let status = garden_cell.plot_status();
        assert(status == PlotStatus::AlivePlant, 'status should be AlivePlant');
        garden_cell.plant.water_level = 0;
        garden_cell.plant.lose_water();
        let status = garden_cell.plot_status();
        assert(status == PlotStatus::DeadPlant, 'status should be DeadPlant');
    }
}

