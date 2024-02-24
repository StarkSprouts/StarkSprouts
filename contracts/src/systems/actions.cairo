// define the interface
#[starknet::interface]
trait IActions<TContractState> {
    // new 

    // plants the seed types at the given garden indexes
    // array.lengths :=
    fn plant_seeds(self: @TContractState, seeds: Array<usize>, garden_indexes: Array<usize>);
    // waters the plants at the given garden indexes
    fn water_plants(self: @TContractState, garden_indexes: Array<usize>);
    // harvest the seeds from the plants at the given garden indexes, mints seed tokens (1155) to player
    fn harvest_plants(self: @TContractState, garden_indexes: Array<usize>);
    // old
    fn spawn(self: @TContractState);
    fn move(self: @TContractState, direction: dojo_starter::models::moves::Direction);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::IActions;

    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{position::{Position, Vec2}, moves::{Moves, Direction}};

    // declaring custom event struct
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        // new
        PlantWatered: PlantWatered,
        PlantHarvested: PlantHarvested,
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
    struct PlantsWatered {
        #[key]
        user: ContractAddress,
        timestamp: u64,
        garden_indexes: Span<usize>,
    }

    #[derive(Drop, starknet::Event)]
    struct PlantsHarvested {
        garden_indexes: Vec<usize>,
    }

    // old
    fn next_position(mut position: Position, direction: Direction) -> Position {
        match direction {
            Direction::None => { return position; },
            Direction::Left => { position.vec.x -= 1; },
            Direction::Right => { position.vec.x += 1; },
            Direction::Up => { position.vec.y -= 1; },
            Direction::Down => { position.vec.y += 1; },
        };
        position
    }


    // impl: implement functions specified in trait
    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        // new
        fn water_plants(self: @ContractState, garden_indexes: Array<usize>) {
            // Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's current position from the world.
            let position = get!(world, player, (Position));

            // Retrieve the player's move data, e.g., how many moves they have left.
            let moves = get!(world, player, (Moves));

            // Update the world state with the new data.
            // 1. Set players moves to 10
            // 2. Move the player's position 100 units in both the x and y direction.
            set!(
                world,
                (
                    Moves { player, remaining: 100, last_direction: Direction::None },
                    Position { player, vec: Vec2 { x: 10, y: 10 } },
                )
            );
        }

        // old
        // ContractState is defined by system decorator expansion
        fn spawn(self: @ContractState) {
            // Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's current position from the world.
            let position = get!(world, player, (Position));

            // Retrieve the player's move data, e.g., how many moves they have left.
            let moves = get!(world, player, (Moves));

            // Update the world state with the new data.
            // 1. Set players moves to 10
            // 2. Move the player's position 100 units in both the x and y direction.
            set!(
                world,
                (
                    Moves { player, remaining: 100, last_direction: Direction::None },
                    Position { player, vec: Vec2 { x: 10, y: 10 } },
                )
            );
        }

        // Implementation of the move function for the ContractState struct.
        fn move(self: @ContractState, direction: Direction) {
            // Access the world dispatcher for reading.
            let world = self.world_dispatcher.read();

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();

            // Retrieve the player's current position and moves data from the world.
            let (mut position, mut moves) = get!(world, player, (Position, Moves));

            // Deduct one from the player's remaining moves.
            moves.remaining -= 1;

            // Update the last direction the player moved in.
            moves.last_direction = direction;

            // Calculate the player's next position based on the provided direction.
            let next = next_position(position, direction);

            // Update the world state with the new moves data and position.
            set!(world, (moves, next));

            // Emit an event to the world to notify about the player's move.
            emit!(world, Moved { player, direction });
        }
    }
}
