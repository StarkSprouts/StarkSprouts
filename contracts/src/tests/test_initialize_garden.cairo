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

    fn now() -> u64 {
        get_block_timestamp()
    }

    fn time_to_water(seconds: u64) -> u8 {
        seconds.try_into().unwrap()
    }

    #[test]
    #[available_gas(30000000000)]
    fn test_plant_grows_and_loses_water() {
        let (world, actions, player) = setup_world();
        actions.initialize_garden();
        actions.plant_seed(1, 1);

        let grow_time = 3_u64;
        let rock_time = 5_u64;
        // let harvest_time = 5_u64;
        let max_water_level = 100_u8;

        set_block_timestamp(now() + grow_time);
        actions.refresh_plot(1);
        let p = actions.get_plant(player, 1);
        assert(p.growth_stage == 1, 'wrong growth stage');
        assert(p.water_level == max_water_level - time_to_water(grow_time), 'wrong water level1');

        set_block_timestamp(now() + grow_time + grow_time);
        actions.refresh_plot(1);
        let p = actions.get_plant(player, 1);
        assert(p.growth_stage == 3, 'wrong growth stage');
        assert(
            p.water_level == max_water_level - time_to_water(3 * grow_time), 'wrong water level2'
        );

        set_block_timestamp(now() + grow_time - 1);
        actions.water_plant(1);
        let p = actions.get_plant(player, 1);
        assert(p.growth_stage == 3, 'wrong growth stage');
        assert(p.water_level == max_water_level, 'wrong water level3');
    }

    #[test]
    #[available_gas(30000000000)]
    fn test_plant_dies() {
        let (world, actions, player) = setup_world();
        actions.initialize_garden();
        actions.plant_seed(1, 1);

        let grow_time = 3_u64;
        let rock_time = 5_u64;
        // let harvest_time = 5_u64;
        let max_water_level = 100_u8;

        /// Grow a little
        set_block_timestamp(now() + 2 * grow_time);
        actions.refresh_plot(1);
        let p = actions.get_plant(player, 1);
        assert(p.growth_stage == 2, 'wrong growth stage1');
        assert(
            p.water_level == max_water_level - time_to_water(2 * grow_time), 'wrong water level1'
        );

        /// Die 
        set_block_timestamp(now() + max_water_level.into() + 10);
        actions.refresh_plot(1);
        let p = actions.get_plant(player, 1);

        /// Same plant but dead, and no water sub_overflow
        assert(p.is_dead, 'plant should be dead');
        assert(p.growth_stage == 2, 'wrong growth stage2');
        assert(p.water_level == 0, 'wrong water level2');
    }

    #[test]
    #[available_gas(30000000000)]
    fn test_plant_becomes_harvestable() {
        let (world, actions, player) = setup_world();
        actions.initialize_garden();
        actions.plant_seed(1, 1);

        let grow_time = 3_u64;
        let rock_time = 5_u64;
        let harvest_time = 5_u64;
        let max_water_level = 100_u8;

        /// Grow to max level 
        let p = actions.get_plant(player, 1);
        let max_growth_level = p.get_max_growth_level();
        loop {
            set_block_timestamp(get_block_timestamp() + grow_time);
            actions.water_plant(1);
            let mut g: GardenCell = actions.get_garden_cell(player, 1);
            if g.plant.growth_stage == max_growth_level {
                break;
            };
        };

        let p = actions.get_plant(player, 1);

        assert(!p.is_harvestable, 'adult but not harvestable');
        assert(p.last_harvest_date == get_block_timestamp(), 'wrong last harvest date1');

        set_block_timestamp(get_block_timestamp() + harvest_time);
        actions.water_plant(1);
        let p = actions.get_plant(player, 1);
        assert(p.is_harvestable, 'should be harvestable');
        assert(
            p.last_harvest_date == get_block_timestamp() - harvest_time, 'wrong last harvest date2'
        );
        set_block_timestamp(get_block_timestamp() + 1);
        actions.harvest_plant(1);
        let p = actions.get_plant(player, 1);
        assert(!p.is_harvestable, 'should not be harvestable');
        assert(p.last_harvest_date == get_block_timestamp(), 'wrong last harvest date3');
    }

    #[test]
    #[available_gas(30000000000)]
    fn test_remove_dead_plant() {
        let (world, actions, player) = setup_world();
        actions.initialize_garden();
        actions.plant_seed(1, 1);

        let grow_time = 3_u64;
        let rock_time = 5_u64;
        // let harvest_time = 5_u64;
        let max_water_level = 100_u8;

        /// Grow a little before dying 
        set_block_timestamp(now() + 2 * grow_time);
        actions.refresh_plot(1);
        let p = actions.get_plant(player, 1);
        assert(p.growth_stage == 2, 'wrong growth stage');
        /// Die 
        set_block_timestamp(now() + max_water_level.into() + 10);
        actions.refresh_plot(1);
        let p = actions.get_plant(player, 1);
        /// Same plant but dead, and no water sub_overflow
        assert(p.is_dead, 'plant should be dead');
        assert(p.growth_stage == 2, 'wrong growth stage');
        assert(p.water_level == 0, 'wrong water level1');

        actions.remove_dead_plant(1);
        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        let state: PlotStatus = g.plot_status();
        assert(state == PlotStatus::Empty, 'wrong plot status');
    }

    #[test]
    #[available_gas(30000000000)]
    fn test_refresh() {
        let (mut world, mut actions, player) = setup_world();
        actions.initialize_garden();
        actions.plant_seed(1, 1);

        let water_loss_per_sec = 1;
        let grow_time = 3;
        let rock_time = 5;
        let harvest_time = 5;
        let max_water_level: u8 = 100;

        // let now: u8 = get_block_timestamp().try_into().unwrap();

        set_block_timestamp(get_block_timestamp() + 2 * grow_time);
        actions.refresh_plot(1);

        let mut g: GardenCell = actions.get_garden_cell(player, 1);
        assert(
            g.plant.water_level == max_water_level - (2 * grow_time).try_into().unwrap(),
            'wrong water level'
        );

        // g.plant.water_level = max_water_level - (2 * grow_time);
        // g.plant.growth_stage = ;

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

