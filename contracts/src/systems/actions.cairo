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

    /// Harvest the plant at the given garden index
    fn harvest_plant(self: @TContractState, cell_index: u16);
}

#[dojo::contract]
mod actions {
    use super::IActions;

    use starknet::{
        ContractAddress, get_caller_address, get_block_timestamp, info::get_block_number
    };
    use openzeppelin::{
        access::ownable::OwnableComponent,
        upgrades::{UpgradeableComponent, interface::IUpgradeable},
        token::erc20::{ERC20Component, interface::IERC20Metadata}
    };

    use stark_sprouts::{
        models::{
            garden_cell::{GardenCell, GardenCellImpl, PlotStatus},
            plant::{Plant, PlantType, PlantImpl, Felt252IntoPlantType},
            player_stats::{PlayerStats, PlayerStatsImpl},
            token_lookups::{TokenLookups, TokenLookupsImpl, TokenLookupsTrait},
            seed_interface::{ISeedDispatcher, ISeedDispatcherTrait}
        },
    // token::seed::{ISeed, ISeedDispatcher, ISeedDispatcherTrait}
    };
    use core::poseidon::{poseidon_hash_span, PoseidonTrait};

    use debug::PrintTrait;


    const MAX_ROCKS_AT_SPAWN: u8 = 50;
    const TIME_TO_REMOVE_ROCK: u64 = 15; // 15 seconds
    const TIME_FOR_PLANT_TO_HARVEST: u64 = 120;


    #[generate_trait]
    impl Private of PrivateTrait {
        fn assert_cell_index_in_bounds(self: @ContractState, cell_index: u16) {
            assert(cell_index < 225, 'Cell index out of bounds');
        }

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
            if (garden_cell.plot_status() == PlotStatus::AlivePlant) {
                /// Lower the plant's water level
                garden_cell.plant.update_water_level();
                /// Check if plant died
                if garden_cell.plot_status() == PlotStatus::DeadPlant {
                    emit!(world, PlantDied { player, garden_cell });
                }
                /// Update the plant's growth
                garden_cell.plant.update_growth();
                set!(world, (garden_cell,));
            }
        }

        fn get_seed_dispatcher(self: @ContractState, seed_id: u256) -> ISeedDispatcher {
            let world = self.world_dispatcher.read();

            let seed_id: felt252 = seed_id.try_into().unwrap();

            let mut token_lookup: TokenLookups = get!(world, (seed_id), (TokenLookups,));

            let seed_contract_address = token_lookup.erc20_address;
            ISeedDispatcher { contract_address: seed_contract_address }
        }

        fn mint_seed(self: @ContractState, seed_id: u256) {
            let seed_dispatcher = self.get_seed_dispatcher(seed_id);
            let player = get_caller_address();
            seed_dispatcher.mint_seeds(player, 1);
        }

        fn burn_seed(self: @ContractState, seed_id: u256) {
            let seed_dispatcher = self.get_seed_dispatcher(seed_id);
            let player = get_caller_address();
            seed_dispatcher.burn_seeds(player, 1);
        }
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        /// Initializes a player's garden
        fn initialize_garden(self: @ContractState) {
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
                garden_cell.set_has_rock(true);
                /// Update the garden cell
                set!(world, (garden_cell,));
                i += 1;
            };
            /// Mint the player some seeds
            let mut i = 0;
            loop {
                if i == 3 {
                    break;
                }
                /// Get new random int
                random_seed = poseidon_hash_span((array![random_seed]).span());
                random_int = random_seed.into();
                /// Convert the random seed to a number of seeds to mint, [1-13] inclusive
                let token_id = (random_int % 14);
                self.mint_seed(token_id);
            }
        // todo: mint random seeds 
        }

        /// Refresh a player's garden state
        fn refresh_garden(self: @ContractState) {
            self.assert_player_has_garden();
            /// Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            /// Loop through the player's garden cells
            let mut cell_index = 0_u16;
            loop {
                if cell_index == 225 {
                    break;
                }
                let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
                /// If the cell has a plant, updates its water level and growth
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
                    garden_cell.set_has_rock(false);
                    player_stats.finish_rock_removal();
                    set!(world, (garden_cell,));
                    set!(world, (player_stats,));
                }
            }
        }

        /// Water a plant at the given garden index
        fn water_plant(self: @ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.assert_cell_index_in_bounds(cell_index);
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

        /// Start rock removal at the given garden index
        fn remove_rock(self: @ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.assert_cell_index_in_bounds(cell_index);

            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
            let mut player_stats: PlayerStats = get!(world, (player), (PlayerStats,));

            assert(garden_cell.plot_status() == PlotStatus::Rock, 'No rock to remove');
            assert(!player_stats.rock_pending, 'Still removing a rock');

            player_stats.start_rock_removal(cell_index);

            // set!(world, (garden_cell,));
            set!(world, (player_stats,));
        // emit!(world, RockRemoved { player, garden_cell });
        }

        /// Remove a dead plant from the garden at the given garden index
        fn remove_dead_plant(self: @ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.assert_cell_index_in_bounds(cell_index);

            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));

            assert(garden_cell.plot_status() == PlotStatus::DeadPlant, 'No dead plant to remove');
            garden_cell.plant.reset();

            set!(world, (garden_cell,));
        // emit!(world, DeadPlantRemoved { player, garden_cell });
        }

        fn plant_seed(self: @ContractState, seed_id: u256, cell_index: u16) {
            self.assert_player_has_garden();
            self.assert_cell_index_in_bounds(cell_index);
            self.refresh_plot(cell_index);

            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));

            assert(garden_cell.plot_status() == PlotStatus::Empty, 'Cell is not empty');

            self.burn_seed(seed_id);
            garden_cell.plant_seed(seed_id, cell_index);

            set!(world, (garden_cell,));
        // emit!(world, DeadPlantRemoved { player, garden_cell });
        }

        fn harvest_plant(self: @ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.assert_cell_index_in_bounds(cell_index);
            self.refresh_plot(cell_index);

            let world = self.world_dispatcher.read();
            let player = get_caller_address();

            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));

            assert(garden_cell.plant.is_harvestable, 'Plant not ready for harvest');

            garden_cell.plant.harvest();

            let seed_id: felt252 = garden_cell.plant.plant_type.into();
            let seed_id: u256 = seed_id.into();

            self.mint_seed(seed_id);

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
