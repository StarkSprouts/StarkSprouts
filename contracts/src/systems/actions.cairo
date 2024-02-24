// define the interface
#[starknet::interface]
trait IActions<TContractState> {
    /// Updates a player's garden state
    fn update_garden(self: @TContractState, player: starknet::ContractAddress);

    /// Remove a rock from the garden
    fn remove_rock(self: @TContractState, cell_index: u16);

    /// Remove a dead plant from the garden 
    fn remove_dead_plant(self: @TContractState, cell_index: u16);

    /// Top off the water level fro an array of garden indexes
    fn water_plants(self: @TContractState, cell_indexes: Array<u16>);


    // plants the seed types at the given garden indexes
    // array.lengths :=
    fn plant_seeds(self: @TContractState, seeds: Array<usize>, cell_indexes: Array<u16>);
    // harvest the seeds from the plants at the given garden indexes, mints seed tokens (1155) to player
    fn harvest_plants(self: @TContractState, cell_indexes: Array<u16>);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::IActions;

    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use stark_sprouts::models::{
        garden_cell::{GardenCell, GardenCellImpl}, plant::{Plant, PlantType, PlantImpl},
    };

    // declaring custom event struct
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        // new
        PlantDied: PlantDied,
        RockRemoved: RockRemoved,
        DeadPlantRemoved: DeadPlantRemoved,
        PlantsWatered: PlantsWatered,
        PlantsHarvested: PlantsHarvested,
    }


    #[derive(Drop, starknet::Event)]
    struct RockRemoved {
        #[key]
        player: ContractAddress,
        garden_cell: GardenCell,
    }

    #[derive(Drop, starknet::Event)]
    struct DeadPlantRemoved {
        #[key]
        player: ContractAddress,
        garden_cell: GardenCell,
    }

    #[derive(Drop, starknet::Event)]
    struct PlantDied {
        #[key]
        player: ContractAddress,
        garden_cell: GardenCell,
    }

    #[derive(Drop, starknet::Event)]
    struct PlantsWatered {
        #[key]
        player: ContractAddress,
        timestamp: u64,
        cell_indexes: Span<u16>,
    }

    #[derive(Drop, starknet::Event)]
    struct PlantsHarvested {
        cell_indexes: Span<u16>,
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
                    /// If the cell has a plant, update its water level
                    if garden_cell.has_plant() {
                        garden_cell.plant.update_water_level();
                        /// Check if plant is dead
                        if garden_cell.plant.plant_type == PlantType::Dead {
                            emit!(world, PlantDied { player, garden_cell });
                        }
                        /// Update garden_cell
                        set!(world, (garden_cell));
                    }
                }
                cell_index += 1;
            }
        }

        fn remove_rock(self: @ContractState, cell_index: u16) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));

            assert(garden_cell.has_rock, 'No rock to remove');
            garden_cell.remove_rock();

            set!(world, (garden_cell,));
            emit!(world, RockRemoved { player, garden_cell });
        }

        fn remove_dead_plant(self: @ContractState, cell_index: u16) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));

            assert(garden_cell.has_plant(), 'No dead plant to remove');
            garden_cell.remove_dead_plant();

            set!(world, (garden_cell,));
            emit!(world, DeadPlantRemoved { player, garden_cell });
        }

        // Water an array of garden indexes
        fn water_plants(self: @ContractState, mut cell_indexes: Array<u16>) { //.
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut watered_cells = array![];

            loop {
                match cell_indexes.pop_front() {
                    Option::Some(cell_index) => {
                        let mut garden_cell: GardenCell = get!(
                            world, (player, cell_index), (GardenCell,)
                        );

                        if garden_cell.has_plant() {
                            garden_cell.plant.water_plant();
                            set!(world, (garden_cell,));
                            watered_cells.append(cell_index);
                        }
                    },
                    Option::None => { break; }
                }
            };

            emit!(
                world,
                PlantsWatered {
                    player, timestamp: get_block_timestamp(), cell_indexes: watered_cells.span()
                }
            );
        } // .
        // Access the world dispatcher for reading.
        // top up water state: auto-quench

        // check time from last water, and upgrade plant if needed

        /////////////

        fn plant_seeds(self: @ContractState, seeds: Array<usize>, cell_indexes: Array<u16>) {}
        fn harvest_plants(self: @ContractState, cell_indexes: Array<u16>) {}
    }
}
