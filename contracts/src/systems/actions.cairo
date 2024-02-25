// define the interface
#[starknet::interface]
trait IActions<TContractState> {
    /// Initialize a garden for the player
    fn initialize_garden(self: @TContractState);

    /// Refresh a player's garden state
    fn refresh_garden(self: @TContractState);

    /// Top off the water level for a plant
    fn water_plant(self: @TContractState, cell_index: u16);

    /// Remove a rock from the garden
    fn remove_rock(self: @TContractState, cell_index: u16);

    /// Remove a dead plant from the garden 
    fn remove_dead_plant(self: @TContractState, cell_index: u16);

    /// Plants the seed type at the given garden index
    /// @dev todo: implement token burning
    fn plant_seed(self: @TContractState, seed_id: u256, cell_index: u16);


    // implementing 

    /// 
    /// not implemented yet
    // plants the seed types at the given garden indexes
    // array.lengths :=
    // harvest the seeds from the plants at the given garden indexes, mints seed tokens (1155) to player
    fn harvest_plant(self: @TContractState, cell_index: u16);
// fn start_garden, creates new garden and randomizes where rocks go
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::IActions;

    use starknet::{
        ContractAddress, get_caller_address, get_block_timestamp, info::get_block_number
    };

    use stark_sprouts::models::{
        garden_cell::{GardenCell, GardenCellImpl, PlotStatus},
        plant::{Plant, PlantType, PlantImpl, Felt252IntoPlantType},
        player_stats::{PlayerStats, PlayerStatsImpl},
    };
    use core::poseidon::{poseidon_hash_span, PoseidonTrait};


    const MAX_ROCKS_AT_SPAWN: u8 = 50;
    const TIME_TO_REMOVE_ROCK: u64 = 15; // 15 seconds
    const TIME_FOR_PLANT_TO_HARVEST: u64 = 120;


    #[generate_trait]
    impl Private of PrivateTrait {
        fn has_garden(self: @ContractState) -> bool {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let player_stats: PlayerStats = get!(world, (player), (PlayerStats,));
            player_stats.has_garden
        }

        fn assert_player_has_garden(self: @ContractState) {
            assert(self.has_garden(), 'Player does not have a garden');
        }

        fn assert_player_does_not_have_garden(self: @ContractState) {
            assert(!self.has_garden(), 'Player already has a garden');
        }

        fn refresh_plot(self: @ContractState, cell_index: u16) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
            garden_cell.plant.update_water_level();
            /// Check if plant died when water level updated
            if garden_cell.plot_status() == PlotStatus::DeadPlant {
                emit!(world, PlantDied { player, garden_cell });
            }
            garden_cell.plant.update_growth();
            /// Check if plant is harvestable
            if garden_cell.plant.growth_stage == garden_cell.plant.get_max_growth_level() {
                /// Time since last harvest 
                let time_since_last_harvest = get_block_timestamp()
                    - garden_cell.plant.last_harvest_date;
                /// If the plant is harvestable, set the harvestable flag
                if time_since_last_harvest >= TIME_FOR_PLANT_TO_HARVEST {
                    garden_cell.plant.set_harvestable();
                }
            }
            set!(world, (garden_cell,));
        }
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        /// Initializes a player's garden
        fn initialize_garden(self: @ContractState) {
            /// Does player already have a garden?
            self.assert_player_does_not_have_garden();

            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            /// Create a new garden
            let mut player_stats: PlayerStats = get!(world, (player), (PlayerStats,));
            player_stats.toggle_has_garden();
            set!(world, (player_stats,));
            /// Create a sudo-random seed  
            let mut seed: felt252 = player.into()
                + get_block_timestamp().into()
                + get_block_number().into();
            let mut random_seed = poseidon_hash_span((array![seed]).span());
            /// Convert the random seed to a number of rocks to spawn, [0 - MAX_ROCKS_AT_SPAWN]
            let mut random_int: u256 = random_seed.into();
            random_int = random_int % (MAX_ROCKS_AT_SPAWN + 1).into();
            let number_of_rocks: u8 = random_int.try_into().unwrap();
            /// Place the rocks in the garden
            let mut i = 0;
            loop {
                if i == number_of_rocks {
                    break;
                }
                /// Create a new random seed
                random_seed = poseidon_hash_span((array![random_seed]).span());
                random_int = random_seed.into();
                /// Convert the random seed to a cell index, [0 - 224]
                let random_cell_index: u16 = (random_int % 225).try_into().unwrap();
                /// Get the garden cell
                let mut garden_cell: GardenCell = get!(
                    world, (player, random_cell_index), (GardenCell,)
                );
                garden_cell.toggle_rock();
                /// Update the garden cell
                set!(world, (garden_cell,));
                i += 1;
            };
        }

        /// Refresh a player's garden state
        fn refresh_garden(self: @ContractState) {
            self.assert_player_has_garden();
            // Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut cell_index = 0_u16;
            loop {
                if cell_index == 225 {
                    break;
                }
                let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
                /// If the cell has a plant, update its water level
                if garden_cell.plot_status() == PlotStatus::AlivePlant {
                    self.refresh_plot(cell_index);
                }
                cell_index += 1;
            };
            /// If the player's rock removal is finished, update 
            let mut player_stats: PlayerStats = get!(world, (player), (PlayerStats,));
            if player_stats.rock_pending {
                let time_since_rock_removal = get_block_timestamp()
                    - player_stats.rock_removal_started_date;
                if time_since_rock_removal >= TIME_TO_REMOVE_ROCK {
                    let cell_index = player_stats.rock_pending_cell_index;
                    let mut garden_cell: GardenCell = get!(
                        world, (player, cell_index), (GardenCell,)
                    );
                    garden_cell.toggle_rock();
                    player_stats.finish_rock_removal();
                    set!(world, (garden_cell,));
                    set!(world, (player_stats,));
                }
            }
        }

        // Water a plant at the given garden index
        fn water_plant(self: @ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.refresh_plot(cell_index);

            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));

            if garden_cell.plot_status() == PlotStatus::AlivePlant {
                garden_cell.plant.water_plant();
                set!(world, (garden_cell,));
            }
        // emit!(
        //     world,
        //     PlantsWatered {
        //         player, timestamp: get_block_timestamp(), cell_indexes: watered_cells.span()
        //     }
        // );
        }

        /// Remove a rock from the garden at the given garden index
        fn remove_rock(self: @ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.refresh_plot(cell_index);
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
            let mut player_stats: PlayerStats = get!(world, (player), (PlayerStats,));
            assert(garden_cell.plot_status() == PlotStatus::Rock, 'No rock to remove');
            assert(!player_stats.rock_pending, 'Still removing a rock');

            player_stats.start_rock_removal(cell_index);

            set!(world, (garden_cell,));
            set!(world, (player_stats,));

            emit!(world, RockRemoved { player, garden_cell });
        }

        /// Remove a dead plant from the garden at the given garden index
        fn remove_dead_plant(self: @ContractState, cell_index: u16) {
            self.assert_player_has_garden();

            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));

            assert(garden_cell.plot_status() == PlotStatus::DeadPlant, 'No dead plant to remove');
            garden_cell.plant.reset();

            set!(world, (garden_cell,));
            emit!(world, DeadPlantRemoved { player, garden_cell });
        }

        fn plant_seed(self: @ContractState, seed_id: u256, cell_index: u16) {
            self.assert_player_has_garden();
            self.refresh_plot(cell_index);

            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));

            assert(garden_cell.plot_status() == PlotStatus::Empty, 'Cell is not empty');

            garden_cell.plant_seed(seed_id, cell_index);

            set!(world, (garden_cell,));
        // emit!(world, DeadPlantRemoved { player, garden_cell });
        }

        fn harvest_plant(self: @ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.refresh_plot(cell_index);

            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));

            assert(garden_cell.plant.is_harvestable, 'Plant not ready for harvest');

            garden_cell.plant.harvest();

            set!(world, (garden_cell,));
        }
    }

    /// Events 
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
}
