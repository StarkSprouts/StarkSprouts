#[cfg(test)]
mod tests {
    use starknet::{class_hash::Felt252TryIntoClassHash, ContractAddress};
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
        let mut models = array![
            garden_cell::TEST_CLASS_HASH,
            player_stats::TEST_CLASS_HASH,
            token_lookups::TEST_CLASS_HASH
        ];
        let world = spawn_test_world(models);
        let contract_address = world
            .deploy_contract('salt', actions::TEST_CLASS_HASH.try_into().unwrap());
        (
            world,
            IActionsDispatcher { contract_address },
            starknet::contract_address_const::<'player'>()
        )
    }


    #[test]
    #[available_gas(10000000)]
    fn test_set_token_lookups() {
        let (world, actions, player) = setup_world();
        let mut lookups: Array<ContractAddress> = array![
            starknet::contract_address_const::<1>(),
            starknet::contract_address_const::<2>(),
            starknet::contract_address_const::<3>(),
            starknet::contract_address_const::<4>(),
            starknet::contract_address_const::<5>(),
            starknet::contract_address_const::<6>(),
            starknet::contract_address_const::<7>(),
            starknet::contract_address_const::<8>(),
            starknet::contract_address_const::<9>(),
            starknet::contract_address_const::<10>(),
            starknet::contract_address_const::<11>(),
            starknet::contract_address_const::<12>(),
            starknet::contract_address_const::<13>(),
        ];
        actions.set_token_lookups(lookups.clone());
    // let token_lookups = actions.get_token_lookups(); == 
    }
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

