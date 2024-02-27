use starknet::ContractAddress;
use stark_sprouts::systems::actions::actions::TIME_TO_REMOVE_ROCK;

#[derive(Model, Copy, Drop, Serde)]
struct PlayerStats {
    #[key]
    player: ContractAddress,
    has_garden: bool,
    rock_pending: bool,
    rock_pending_cell_index: u16,
    rock_removal_started_date: u64,
}

trait PlayerStatsTrait {
    /// Set if a user has a garden or not
    fn set_has_garden(ref self: PlayerStats, has_garden: bool);
    /// Start the rock removal process
    fn start_rock_removal(ref self: PlayerStats, cell_index: u16);
    /// Finish the rock removal process
    fn finish_rock_removal(ref self: PlayerStats);
}

impl PlayerStatsImpl of PlayerStatsTrait {
    /// Set if a user has a garden or not
    fn set_has_garden(ref self: PlayerStats, has_garden: bool) {
        self.has_garden = has_garden;
    }

    /// Start the rock removal process
    fn start_rock_removal(ref self: PlayerStats, cell_index: u16) {
        assert(!self.rock_pending, 'Rock removal already pending');
        self.rock_pending = true;
        self.rock_pending_cell_index = cell_index;
        self.rock_removal_started_date = starknet::get_block_timestamp();
    }

    /// Finish the rock removal process
    fn finish_rock_removal(ref self: PlayerStats) {
        // assert(self.rock_pending, 'No rock removal pending');
        /// Check if rock removal is finished
        // let time_since_rock_removal_started = starknet::get_block_timestamp()
        //     - self.rock_removal_started_date;
        // assert(time_since_rock_removal_started >= TIME_TO_REMOVE_ROCK, 'Rock still being removed');
        self.rock_pending = false;
        self.rock_pending_cell_index = 0;
        self.rock_removal_started_date = 0;
    }
}

#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use super::{PlayerStats, PlayerStatsTrait, PlayerStatsImpl};
    use stark_sprouts::systems::actions::actions::TIME_TO_REMOVE_ROCK;


    fn init_player_stats() -> PlayerStats {
        PlayerStats {
            player: starknet::contract_address_const::<'player'>(),
            has_garden: true,
            rock_pending: false,
            rock_pending_cell_index: 0,
            rock_removal_started_date: 0,
        }
    }

    #[test]
    #[available_gas(1000000)]
    fn test_set_has_garden() {
        let mut player_stats = init_player_stats();
        assert(player_stats.has_garden == true, 'has_garden should be true');
        player_stats.set_has_garden(false);
        assert(player_stats.has_garden == false, 'has_garden should be false');
        player_stats.set_has_garden(true);
        assert(player_stats.has_garden == true, 'has_garden should be true');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_start_rock_removal() {
        let mut player_stats = init_player_stats();
        player_stats.start_rock_removal(1);
        assert(player_stats.rock_pending == true, 'rock_pending should be true');
        assert(player_stats.rock_pending_cell_index == 1, 'wrong rock_pending_cell_index');
        assert(
            player_stats.rock_removal_started_date == starknet::get_block_timestamp(),
            'wrong rock_removal_started_date'
        );
    }

    #[test]
    #[available_gas(1000000)]
    fn test_finish_rock_removal() {
        starknet::testing::set_block_timestamp(123);
        let mut player_stats = init_player_stats();
        player_stats.start_rock_removal(1);
        assert(player_stats.rock_pending == true, 'rock_pending should be true');
        assert(player_stats.rock_pending_cell_index == 1, 'wrong rock_pending_cell_index');
        assert(player_stats.rock_removal_started_date == 123, 'wrong rock_removal_started_date');
        starknet::testing::set_block_timestamp(123 + TIME_TO_REMOVE_ROCK);
        player_stats.finish_rock_removal();
        assert(player_stats.rock_pending == false, 'rock_pending should be false');
        assert(player_stats.rock_pending_cell_index == 0, 'wrong rock_pending_cell_index');
        assert(player_stats.rock_removal_started_date == 0, 'wrong rock_removal_started_date');
    }
}
