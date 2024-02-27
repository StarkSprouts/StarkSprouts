use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct WorldInit {
    #[key]
    id: u8,
    is_init: bool,
}

trait WorldInitTrait {
    fn init_world(ref self: WorldInit);
}

impl WorldInitImpl of WorldInitTrait {
    fn init_world(ref self: WorldInit) {
        assert(!self.is_init, 'World already initialized');
        self.is_init = true;
    }
}

#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use super::{WorldInit, WorldInitTrait, WorldInitImpl};

    fn get() -> WorldInit {
        WorldInit { id: 0, is_init: false, }
    }

    #[test]
    #[available_gas(1000000)]
    fn test_init_world() {
        let mut world_init = get();
        world_init.init_world();
        assert(world_init.is_init, 'World should be initialized');
    }

    #[test]
    #[available_gas(1000000)]
    #[should_panic()]
    fn test_init_world_twice() {
        let mut world_init = get();
        world_init.init_world();
        world_init.init_world();
    }
}
