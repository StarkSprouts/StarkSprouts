#[cfg(test)]
mod tests {
    use starknet::{class_hash::Felt252TryIntoClassHash, ContractAddress};
    use starknet::testing::set_block_timestamp;
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
        starknet::testing::set_block_timestamp(100);
        starknet::testing::set_contract_address(starknet::contract_address_const::<'player'>());
        let mut models = array![
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

    #[test]
    #[available_gas(3000000000)]
    fn test_flow() {
        let (mut world, mut actions, mut player) = setup_world();

        // let g: GardenCell = get!(world, (player, 1), (GardenCell,));
        // let f: felt252 = g.plant.plant_type.into();
        // f.print();

        actions.initialize_garden();
        actions.plant_seed(1, 1);

        let g0: GardenCell = actions.get_garden_cell(player, 1);
        g0.plant.last_water_date.print()
    //     let g: GardenCell = get!(world, (player, 1), (GardenCell,));
    //     let f: felt252 = g.plant.plant_type.into();
    //     f.print();
    // ////
    // let mut g: GardenCell = actions.get_garden_cell(player, 1);
    // g.plant.last_water_date = 123;
    // set!(world, (g));

    // let x: felt252 = world.contract_address.into();
    // x.print();
    // let g: GardenCell = get!(world, (player, 1), (GardenCell,));
    // let g2: GardenCell = get!(world, (player, 1), (GardenCell,));
    // g.plant.last_water_date.print();
    // g2.plant.last_water_date.print();
    // starknet::get_block_timestamp().print();
    }
/// come back to this, for some reason they are not being set, or when being read, not working
// #[test]
// #[available_gas(1000000000)]
// fn test_set_token_lookups() {
//     let (world, actions, player) = setup_world();
//     let mut lookups: Array<ContractAddress> = array![
//         starknet::contract_address_const::<1>(),
//         starknet::contract_address_const::<2>(),
//         starknet::contract_address_const::<3>(),
//         starknet::contract_address_const::<4>(),
//         starknet::contract_address_const::<5>(),
//         starknet::contract_address_const::<6>(),
//         starknet::contract_address_const::<7>(),
//         starknet::contract_address_const::<8>(),
//         starknet::contract_address_const::<9>(),
//         starknet::contract_address_const::<10>(),
//         starknet::contract_address_const::<11>(),
//         starknet::contract_address_const::<12>(),
//         starknet::contract_address_const::<13>(),
//     ];
//     let b = lookups.clone();

//     actions.set_token_lookups(lookups);

//     let a = actions.get_token_lookups();

//     a.len().print();
//     b.len().print();

//     let mut i = 0;
//     loop {
//         if i == 14 {
//             break;
//         }
//         (*a.at(i)).print();
//         (*b.at(i)).print();
//         // (*lookups.at(i)).print();
//         // assert(a[i] == lookups[i], 'wrong token lookups');
//         i += 1;
//     };
// // assert(actions.get_token_lookups() == lookups, 'wrong token lookups');
// }
// #[test]
// #[available_gas(3000000000)]
// fn test_initialize_garden() {
//     let player = starknet::contract_address_const::<0x0>();
//     let actions = setup_world();

//     actions.initialize_garden();
// }

/// do easy ones later above

// #[test]
// #[available_gas(3000000000)]
// fn test_remove_rock() {
//     let player = starknet::contract_address_const::<0x0>();
//     let actions = setup_world();

//     actions.initialize_garden();
//     actions.remove_rock(1);
// }

// #[test]
// #[available_gas(3000000000)]
// fn test_plant_type_default() {
//     // caller
//     let player = starknet::contract_address_const::<0x0>();

//     // models
//     let mut models = array![garden_cell::TEST_CLASS_HASH];

//     // deploy world with models
//     let world = spawn_test_world(models);

//     // deploy systems contract
//     let contract_address = world
//         .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
//     let actions_system = IActionsDispatcher { contract_address };

//     // call initialize_garden
//     let mut gs = get!(world, (player, 2), (GardenCell,));

//     actions_system.initialize_garden();
//     actions_system.plant_seed(1, 2);

//     let mut gs = get!(world, (player, 2), (GardenCell,));
//     let b: bool = gs.plant.plant_type == PlantType::Bell;
//     b.print();
// }
}

