#[cfg(test)]
mod tests {
    use starknet::{
        get_block_timestamp, class_hash::Felt252TryIntoClassHash, ContractAddress,
        contract_address_const
    };
    use starknet::testing::{set_block_timestamp, set_contract_address};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};
    use stark_sprouts::{
        models::{
            garden_cell::{GardenCell, GardenCellImpl, PlotStatus, garden_cell},
            plant::{Plant, PlantImpl, PlantType},
            player_stats::{PlayerStats, PlayerStatsImpl, player_stats},
            token_lookups::{TokenLookups, TokenLookupsImpl, token_lookups},
        },
        systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}},
    };
    use debug::PrintTrait;


    fn setup_world() -> (IWorldDispatcher, IActionsDispatcher, ContractAddress) {
        set_block_timestamp(100);
        set_contract_address(starknet::contract_address_const::<'player'>());
        let models = array![
            garden_cell::TEST_CLASS_HASH,
            player_stats::TEST_CLASS_HASH,
            token_lookups::TEST_CLASS_HASH
        ];
        let mut world = spawn_test_world(models);
        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        let mut actions = IActionsDispatcher { contract_address };
        (world, actions, starknet::contract_address_const::<'player'>())
    }

    /// Plant Seed ///

    #[test]
    #[available_gas(30000000000)]
    fn test_plant_seed() {
        let (mut world, mut actions, player) = setup_world();

        actions.initialize_garden();
        actions.plant_seed(1, 1);
        let mut g: GardenCell = actions.get_garden_cell(player, 1);

        assert(g.plant.plant_type == PlantType::Bell, 'wrong plant type');
        assert(g.plot_status() == PlotStatus::AlivePlant, 'wrong plot status');
        assert(g.plant.last_water_date == 100, 'wrong last water date');
        assert(g.plant.water_level == 100, 'wrong water level');
    }

    #[test]
    #[available_gas(30000000000)]
    #[should_panic()]
    fn test_plant_seed_again() {
        let (mut world, mut actions, player) = setup_world();

        actions.initialize_garden();
        actions.plant_seed(1, 1);
        actions.plant_seed(1, 1);
    }

    #[test]
    #[available_gas(30000000000)]
    #[should_panic()]
    fn test_water_plant_out_of_bounds() {
        let (mut world, mut actions, player) = setup_world();
        actions.initialize_garden();
        actions.plant_seed(1, 225);
    }

    #[test]
    #[available_gas(30000000000)]
    #[should_panic()]
    fn test_water_plant_no_garden() {
        let (mut world, mut actions, player) = setup_world();
        actions.initialize_garden();
        starknet::testing::set_contract_address(contract_address_const::<0x9>());
        let x = get!(world, (contract_address_const::<0x9>()), PlayerStats);
        actions.plant_seed(1, 1);
    }

    #[test]
    #[available_gas(30000000000)]
    #[should_panic()]
    fn test_plant_seed_non_empty_plot() {
        let (mut world, mut actions, player) = setup_world();
        actions.initialize_garden();
        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        g.has_rock = true;
        set!(world, (g));
        actions.plant_seed(1, 1);
    }
    /// Test Refresh /// 

    #[test]
    #[available_gas(30000000000)]
    fn test_refresh() {
        let (mut world, mut actions, player) = setup_world();
        actions.initialize_garden();
        actions.plant_seed(1, 1);

        set_block_timestamp(get_block_timestamp() + 6);
        actions.refresh_plot(1);
        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        g.plant.water_level = 94;
        g.plant.growth_stage = 2;

        loop {
            set_block_timestamp(get_block_timestamp() + 6);
            actions.water_plant(1);
            let mut g: GardenCell = actions.get_garden_cell(player, 1);
            if g.plant.growth_stage == g.plant.get_max_growth_level() {
                break;
            };
        };
        set_block_timestamp(get_block_timestamp() + 6);
        actions.water_plant(1);
        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        assert(g.plant.water_level == 100, 'wrong water level');
        assert(g.plant.last_water_date == get_block_timestamp(), 'wrong last water date');
        assert(g.plant.is_harvestable, 'plant should be harvestable');

        actions.harvest_plant(1);
        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        assert(g.plant.is_harvestable == false, 'didnt harvest');
        assert(g.plant.last_harvest_date == get_block_timestamp(), 'wrong last harvest date');

        set_block_timestamp(get_block_timestamp() + 10000);
        actions.refresh_plot(1);
        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        assert(g.plant.water_level == 0, 'wrong water level');
        assert(g.plant.is_dead, 'plant should be dead');

        actions.remove_dead_plant(1);

        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        assert(g.plant.plant_type == PlantType::None, 'wrong plant type');
        assert(g.plot_status() == PlotStatus::Empty, 'wrong plot status');
    }


    /// test rock removal 
    #[test]
    #[available_gas(30000000000)]
    fn test_rock_removal() {
        let (mut world, mut actions, player) = setup_world();
        actions.initialize_garden();

        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        g.has_rock = true;
        set!(world, (g));
        actions.remove_rock(1);

        set_block_timestamp(get_block_timestamp() + 4);
        actions.refresh_plots(array![1_u16]);
        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        assert(g.has_rock == true, 'rock should be pending');

        set_block_timestamp(get_block_timestamp() + 2);
        actions.refresh_plots(array![1_u16]);
        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        assert(g.has_rock == false, 'rock should be removed');
    }
// #[test]
// #[available_gas(30000000000)]
// fn test
// 
}

