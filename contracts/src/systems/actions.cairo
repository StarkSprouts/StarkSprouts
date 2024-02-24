// define the interface
#[starknet::interface]
trait IActions<TContractState> {
    // new 

    /// Updates a user's garden state. 
    fn update_garden(self: @TContractState, player: starknet::ContractAddress);

    // plants the seed types at the given garden indexes
    // array.lengths :=
    fn plant_seeds(self: @TContractState, seeds: Array<usize>, garden_indexes: Array<u8>);
    // waters the plants at the given garden indexes
    fn water_plants(self: @TContractState, garden_indexes: Array<u8>);
    // harvest the seeds from the plants at the given garden indexes, mints seed tokens (1155) to player
    fn harvest_plants(self: @TContractState, garden_indexes: Array<u8>);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::IActions;

    use starknet::{ContractAddress, get_caller_address};
    use stark_sprouts::models::{
        position::{Position, Vec2}, moves::{Moves, Direction}, garden_cell::{GardenCell},
        plant::{Plant, PlantType, PlantImpl}, water::{WaterState}
    };

    // declaring custom event struct
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        // new
        PlantDied: PlantDied,
        PlantsWatered: PlantsWatered,
        PlantsHarvested: PlantsHarvested,
        // old
        Moved: Moved,
    }

    // old
    #[derive(Drop, starknet::Event)]
    struct Moved {
        player: ContractAddress,
        direction: Direction
    }

    // new
    #[derive(Drop, starknet::Event)]
    struct PlantDied {
        #[key]
        player: ContractAddress,
        garden_cell: GardenCell,
    }

    #[derive(Drop, starknet::Event)]
    struct PlantsWatered {
        #[key]
        user: ContractAddress,
        timestamp: u64,
        garden_indexes: Span<usize>,
    }

    #[derive(Drop, starknet::Event)]
    struct PlantsHarvested {
        garden_indexes: Span<usize>,
    }

    // RockRemoved: RockRemoved,    

    // impl: implement functions specified in trait
    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        // new
        fn update_garden(self: @ContractState, player: starknet::ContractAddress) {
            // Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();

            let mut cell_index = 0_u16;
            loop {
                if cell_index >= 225 {
                    break;
                } else {
                    /// Get the garden cell
                    let mut garden_cell: GardenCell = get!(
                        world, (player, cell_index), (GardenCell,)
                    );
                    /// If the cell has a plant
                    if garden_cell.plant.plant_type != PlantType::None {
                        /// Update water level
                        garden_cell.plant = garden_cell.plant.update_water_level();
                        if garden_cell.plant.plant_type == PlantType::None {
                            emit!(world, PlantDied { player, garden_cell });
                        }
                        /// Update garden_cell
                        set!(world, (garden_cell));
                    }
                }
                cell_index += 1;
            }
        }


        // Water an array of garden indexes
        // @dev Watering a plant will increase its water state, by 1 or to the maximum water state?
        // @dev Grow plant to proper state if not dead
        fn water_plants(self: @ContractState, garden_indexes: Array<u8>) {} // .
        // Access the world dispatcher for reading.
        // top up water state: auto-quench

        // check time from last water, and upgrade plant if needed

        /////////////

        fn plant_seeds(self: @ContractState, seeds: Array<usize>, garden_indexes: Array<u8>) {}
        fn harvest_plants(self: @ContractState, garden_indexes: Array<u8>) {}
    }
}
