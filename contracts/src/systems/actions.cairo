use starknet::{ContractAddress};
use stark_sprouts::{
    models::{
        garden_cell::{GardenCell, GardenCellImpl, PlotStatus},
        plant::{Plant, PlantType, PlantImpl, Felt252IntoPlantType},
        player_stats::{PlayerStats, PlayerStatsImpl},
        seed_interface::{ISeedDispatcher, ISeedDispatcherTrait},
        token_lookups::{TokenLookups, TokenLookupsImpl, TokenLookupsTrait},
        world_init::{WorldInit, WorldInitImpl, WorldInitTrait},
    },
};


#[starknet::interface]
trait IActions<TContractState> {
    /// Set seed token address lookups
    fn set_token_lookups(
        ref self: TContractState, seed_addresses: Array<starknet::ContractAddress>
    );
    /// Initialize a garden for the player with random rocks and mint the player some seeds
    fn initialize_garden(ref self: TContractState);
    /// Remove a rock from the garden
    fn remove_rock(ref self: TContractState, cell_index: u16);
    /// Plants the seed type at the given garden index
    fn plant_seed(ref self: TContractState, seed_id: u256, cell_index: u16);
    /// Top off the water level for a plant
    fn water_plant(ref self: TContractState, cell_index: u16);
    /// Harvest the plant at the given garden index
    fn harvest_plant(ref self: TContractState, cell_index: u16);
    /// Remove a dead plant from the garden 
    fn remove_dead_plant(ref self: TContractState, cell_index: u16);
    /// Refresh a specifc plot 
    fn refresh_plot(ref self: TContractState, cell_index: u16);
    /// Refresh the state of the garden for specific cells
    fn refresh_plots(ref self: TContractState, cell_indexes: Array<u16>);
    /// Refresh a player's garden state
    fn refresh_garden(ref self: TContractState);

    /// Get the token lookups for the given seed id
    fn get_token_lookups(self: @TContractState) -> Array<ContractAddress>;

    /// Get the player's stats 
    fn get_player_stats(self: @TContractState, player: ContractAddress) -> PlayerStats;
    /// Get a garden cell 
    fn get_garden_cell(
        self: @TContractState, player: ContractAddress, cell_index: u16
    ) -> GardenCell;
    /// Get an array of garden cells
    fn get_garden_cells(
        self: @TContractState, player: ContractAddress, cell_indexes: Array<u16>
    ) -> Array<GardenCell>;
// get garden cells, 

// get ...
}

#[dojo::contract]
mod actions {
    use super::IActions;
    use stark_sprouts::{
        models::{
            garden_cell::{GardenCell, GardenCellImpl, PlotStatus},
            plant::{Plant, PlantType, PlantImpl, Felt252IntoPlantType},
            player_stats::{PlayerStats, PlayerStatsImpl},
            seed_interface::{ISeedDispatcher, ISeedDispatcherTrait},
            token_lookups::{TokenLookups, TokenLookupsImpl, TokenLookupsTrait},
            world_init::{WorldInit, WorldInitImpl, WorldInitTrait},
        },
    };
    use starknet::{
        ContractAddress, get_caller_address, get_block_timestamp, info::get_block_number
    };
    use openzeppelin::{
        access::ownable::OwnableComponent,
        upgrades::{UpgradeableComponent, interface::IUpgradeable},
        token::erc20::{ERC20Component, interface::IERC20Metadata}
    };
    use core::poseidon::{poseidon_hash_span, PoseidonTrait};
    use debug::PrintTrait;

    const DIM: u16 = 15;
    const STARTING_SEED_COUNT: u8 = 3;
    const MAX_ROCKS_AT_SPAWN: u8 = 50;
    const NUMBER_OF_PLANT_ASSETS: u8 = 13;
    const TIME_TO_REMOVE_ROCK: u64 = 15; // seconds
    const TIME_FOR_PLANT_TO_HARVEST: u64 = 120; // seconds


    /// Internal ///
    #[generate_trait]
    impl Private of PrivateTrait {
        /// Assert the cell index is within bounds
        fn assert_cell_index_in_bounds(self: @ContractState, cell_index: u16) {
            assert(cell_index < DIM * DIM, 'Cell index out of bounds');
        }

        /// Assert the player has a garden
        fn assert_player_has_garden(self: @ContractState) {
            assert(self.has_garden(), 'Player does not have a garden');
        }

        /// Assert the player does not have a garden
        fn assert_player_does_not_have_garden(self: @ContractState) {
            assert(!self.has_garden(), 'Player already has a garden');
        }

        /// Assert that a plot is empty
        fn assert_plot_is_empty(self: @ContractState, ref garden_cell: GardenCell) {
            assert(garden_cell.plot_status() == PlotStatus::Empty, 'Plot is not empty');
        }

        /// Check if the player has a garden
        fn has_garden(self: @ContractState) -> bool {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let player_stats: PlayerStats = get!(world, (player), (PlayerStats,));
            player_stats.has_garden
        }

        /// Refresh a plot by lowering the plant's water level, updating 
        /// its growth stage (if necessary), and marking the plant harvested (if necessary)
        fn _refresh_plot(ref self: ContractState, cell_index: u16) {
            self.assert_cell_index_in_bounds(cell_index);
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
            /// If there is an alive plant in the cell, update its water level and growth, need a way to set 
            if (garden_cell.plot_status() == PlotStatus::AlivePlant) {
                /// Update the plants growth stage and water level
                garden_cell.plant.update_growth();
                /// Check if plant died
                /// @dev Plant dies if it's water level reaches 0
                // if garden_cell.plot_status() == PlotStatus::DeadPlant { 
                // emit!(world, PlantDied { player, garden_cell });
                // }
                set!(world, (garden_cell,));
            }
        }

        /// Finalize rock removal 
        fn finish_rock_removal_if_ready(ref self: ContractState, cell_index: u16,) {
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut player_stats: PlayerStats = get!(world, (player), (PlayerStats,));
            /// If there is a pending rock try to remove it
            let cell_index = player_stats.rock_pending_cell_index;
            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
            player_stats.finish_rock_removal();
            garden_cell.set_has_rock(false);

            set!(world, (garden_cell,));
            set!(world, (player_stats,));
        }

        /// Get the seed dispatcher for the given seed id
        fn get_seed_dispatcher(self: @ContractState, seed_id: u256) -> ISeedDispatcher {
            assert(seed_id <= NUMBER_OF_PLANT_ASSETS.into(), 'Invalid seed id');
            let world = self.world_dispatcher.read();
            let mut token_lookup: TokenLookups = get!(world, (seed_id), (TokenLookups,));

            ISeedDispatcher { contract_address: token_lookup.erc20_address }
        }

        /// Mint the player a seed token
        fn mint_seed(ref self: ContractState, seed_id: u256) {
            self.get_seed_dispatcher(seed_id).mint_seeds(get_caller_address(), 1);
        }

        /// Burn a player's seed token
        fn burn_seed(ref self: ContractState, seed_id: u256) {
            self.get_seed_dispatcher(seed_id).burn_seeds(get_caller_address(), 1);
        }
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        /// Reads /// 
        fn get_token_lookups(self: @ContractState) -> Array<ContractAddress> {
            let world = self.world_dispatcher.read();
            let mut token_lookups: Array<ContractAddress> = array![];
            let mut i = 1_u256;
            loop {
                let mut token_lookup: TokenLookups = get!(world, (i), (TokenLookups,));
                token_lookups.append(token_lookup.erc20_address);
                i += 1;
                if token_lookups.len() == 13 {
                    break;
                }
            };
            token_lookups
        }

        fn get_player_stats(self: @ContractState, player: ContractAddress) -> PlayerStats {
            let world = self.world_dispatcher.read();
            get!(world, (player), (PlayerStats,))
        }

        fn get_garden_cell(
            self: @ContractState, player: ContractAddress, cell_index: u16
        ) -> GardenCell {
            let world = self.world_dispatcher.read();
            get!(world, (player, cell_index), (GardenCell,))
        }

        fn get_garden_cells(
            self: @ContractState, player: ContractAddress, mut cell_indexes: Array<u16>
        ) -> Array<GardenCell> {
            let world = self.world_dispatcher.read();
            let mut garden_cells: Array<GardenCell> = array![];
            loop {
                match cell_indexes.pop_front() {
                    Option::Some(cell_index) => {
                        let garden_cell: GardenCell = get!(
                            world, (player, cell_index), (GardenCell,)
                        );
                        garden_cells.append(garden_cell);
                    },
                    Option::None => { break; }
                }
            };
            garden_cells
        }


        /// Set token lookups
        fn set_token_lookups(
            ref self: ContractState, mut seed_addresses: Array<starknet::ContractAddress>
        ) {
            /// Check all seed addresses are passed in
            assert(seed_addresses.len() == NUMBER_OF_PLANT_ASSETS.into(), 'Array invalid');

            /// Set the world as initialzed 
            /// @dev Reverts if the world has already been initialized
            let world = self.world_dispatcher.read();
            let mut world_init: WorldInit = get!(world, (0), (WorldInit,));
            world_init.init_world();

            /// Set the token lookups for each seed
            let mut i = 1_u16;
            loop {
                match seed_addresses.pop_front() {
                    Option::Some(seed_address) => {
                        let mut token_lookup: TokenLookups = get!(world, (i), (TokenLookups,));
                        token_lookup.set_erc20_address(seed_address);
                        set!(world, (token_lookup,));
                        i += 1;
                    },
                    Option::None => { break; }
                };
            };
        }

        /// Initializes a player's garden
        fn initialize_garden(ref self: ContractState) {
            self.assert_player_does_not_have_garden();
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            /// Create a new garden
            let mut player_stats: PlayerStats = get!(world, (player), (PlayerStats,));
            player_stats.set_has_garden(true);
            set!(world, (player_stats,));
            /// Initializes all cells into torii
            let mut i = 0;
            loop {
                if i == DIM * DIM {
                    break;
                }
                let mut garden_cell: GardenCell = get!(world, (player, i), (GardenCell,));
                garden_cell.set_has_rock(false);
                set!(world, (garden_cell,));
                i += 1;
            };
            /// Create some salt for randomness
            let mut salt: felt252 = player.into()
                + get_block_timestamp().into()
                + get_block_number().into();
            let mut random_seed: felt252 = poseidon_hash_span((array![salt]).span());
            /// Convert the random seed to a number of rocks to spawn, [0, MAX_ROCKS_AT_SPAWN]
            let mut random_int: u256 = random_seed.into();
            random_int = random_int % (MAX_ROCKS_AT_SPAWN + 1).into();
            let number_of_rocks = random_int;
            /// Place the rocks in the garden
            let mut i = 0;
            loop {
                if i == number_of_rocks {
                    break;
                }
                /// Create a new random seed
                random_seed = poseidon_hash_span((array![random_seed]).span());
                random_int = random_seed.into();
                /// Convert the random seed to a cell index, [0, DIM^2)
                let random_cell_index = (random_int % ((DIM * DIM).into()));
                /// Get the garden cell
                // @dev todo: ask about this; u16 and u256 work here, 
                // is there a default val or will an overflow throw an error
                let as_correct_type: u16 = random_cell_index.try_into().unwrap();
                let mut garden_cell: GardenCell = get!(
                    world, (player, as_correct_type), (GardenCell,)
                );
                /// Set the rock
                garden_cell.set_has_rock(true);
                set!(world, (garden_cell,));
                i += 1;
            };
            /// Mint the player some seeds
            let mut i = 0;
            loop {
                if i == STARTING_SEED_COUNT {
                    break;
                }
                /// Create a new random seed
                random_seed = poseidon_hash_span((array![random_seed]).span());
                /// Convert the random seed to a number of seeds to mint, [1, NUMBER_OF_PLANT_ASSETS]
                random_int = random_seed.into();
                let token_id: u256 = ((random_int % NUMBER_OF_PLANT_ASSETS.into()) + 1);
                /// Mint the seed
                // self.mint_seed(token_id); // todo add back
                i += 1;
            }
        }

        /// Refresh a specifc plot
        fn refresh_plot(ref self: ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.assert_cell_index_in_bounds(cell_index);
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
            self._refresh_plot(cell_index);
        }

        /// Refresh the state of the garden for specific cells
        fn refresh_plots(ref self: ContractState, mut cell_indexes: Array<u16>) {
            self.assert_player_has_garden();
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            /// Loop through all of the player's garden cells
            let mut cell_index = 0_u16;
            loop {
                match cell_indexes.pop_front() {
                    Option::Some(cell_index) => {
                        let mut garden_cell: GardenCell = get!(
                            world, (player, cell_index), (GardenCell,)
                        );
                        self._refresh_plot(cell_index);
                    },
                    Option::None => { break; }
                }
            };
            /// If the player's rock removal is finished, update 
            self.finish_rock_removal_if_ready(cell_index);
        }

        /// Refresh a player's entire garden's state
        fn refresh_garden(ref self: ContractState) {
            self.assert_player_has_garden();
            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            /// Loop through all of the player's garden cells
            let mut cell_index = 0_u16;
            loop {
                if cell_index == 225 {
                    break;
                }
                let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
                /// If the cell has a plant, updates its water level and growth
                if garden_cell.plot_status() == PlotStatus::AlivePlant {
                    self._refresh_plot(cell_index);
                }
                cell_index += 1;
            };
            /// If the player's rock removal is finished, update 
            self.finish_rock_removal_if_ready(cell_index);
        }

        /// Water a plant at the given garden index
        fn water_plant(ref self: ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.assert_cell_index_in_bounds(cell_index);
            self._refresh_plot(cell_index);

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
        fn remove_rock(ref self: ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.assert_cell_index_in_bounds(cell_index);

            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
            let mut player_stats: PlayerStats = get!(world, (player), (PlayerStats,));

            assert(garden_cell.plot_status() == PlotStatus::Rock, 'No rock to remove');
            player_stats.start_rock_removal(cell_index);

            set!(world, (player_stats,));
        // emit!(world, RockRemoved { player, garden_cell });
        }

        /// Remove a dead plant from the garden at the given garden index
        fn remove_dead_plant(ref self: ContractState, cell_index: u16) {
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

        /// Plants the seed type at the given garden index
        fn plant_seed(ref self: ContractState, seed_id: u256, cell_index: u16) {
            self.assert_player_has_garden();
            self.assert_cell_index_in_bounds(cell_index);

            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
            self.assert_plot_is_empty(ref garden_cell);

            /// Burn the seed token
            // self.burn_seed(seed_id);
            /// Plant the seed
            garden_cell.plant_seed(seed_id, cell_index);

            set!(world, (garden_cell));

            let x: felt252 = world.contract_address.into();
            x.print();
        // emit!(world, DeadPlantRemoved { player, garden_cell });
        }

        /// Harvest the plant at the given garden index
        fn harvest_plant(ref self: ContractState, cell_index: u16) {
            self.assert_player_has_garden();
            self.assert_cell_index_in_bounds(cell_index);
            self._refresh_plot(cell_index);

            let world = self.world_dispatcher.read();
            let player = get_caller_address();
            let mut garden_cell: GardenCell = get!(world, (player, cell_index), (GardenCell,));
            let seed_id: felt252 = garden_cell.plant.plant_type.into();

            garden_cell.plant.harvest();
            // self.mint_seed(seed_id.into());

            set!(world, (garden_cell,));
        }
    }

    /// Events 
    // declaring custom event struct
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event { // new
    // PlantDied: PlantDied,
    // RockRemoved: RockRemoved,
    // DeadPlantRemoved: DeadPlantRemoved,
    // PlantsWatered: PlantsWatered,
    // PlantsHarvested: PlantsHarvested,
    }
// #[derive(Drop, starknet::Event)]
// struct RockRemoved {
//     #[key]
//     player: ContractAddress,
//     garden_cell: GardenCell,
// }

// #[derive(Drop, starknet::Event)]
// struct DeadPlantRemoved {
//     #[key]
//     player: ContractAddress,
//     garden_cell: GardenCell,
// }

// #[derive(Drop, starknet::Event)]
// struct PlantDied {
//     #[key]
//     player: ContractAddress,
//     garden_cell: GardenCell,
// }

// #[derive(Drop, starknet::Event)]
// struct PlantsWatered {
//     #[key]
//     player: ContractAddress,
//     timestamp: u64,
//     cell_indexes: Span<u16>,
// }

// #[derive(Drop, starknet::Event)]
// struct PlantsHarvested {
//     cell_indexes: Span<u16>,
// }
// RockRemoved: RockRemoved,   
}
