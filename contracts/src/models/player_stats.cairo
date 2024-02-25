use starknet::ContractAddress;

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
    fn toggle_has_garden(ref self: PlayerStats);
    fn start_rock_removal(ref self: PlayerStats, cell_index: u16);
    fn finish_rock_removal(ref self: PlayerStats);
}

impl PlayerStatsImpl of PlayerStatsTrait {
    fn toggle_has_garden(ref self: PlayerStats) {
        self.has_garden = !self.has_garden;
    }

    fn start_rock_removal(ref self: PlayerStats, cell_index: u16) {
        self.rock_pending = true;
        self.rock_pending_cell_index = cell_index;
        self.rock_removal_started_date = starknet::get_block_timestamp();
    }

    fn finish_rock_removal(ref self: PlayerStats) {
        self.rock_pending = false;
        self.rock_pending_cell_index = 0;
        self.rock_removal_started_date = 0;
    }
}

#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use super::{PlayerStats, PlayerStatsTrait, PlayerStatsImpl};

    fn init_player_stats() -> PlayerStats {
        PlayerStats {
            player: starknet::contract_address_const::<'player'>(),
            has_garden: false,
            rock_pending: false,
            rock_pending_cell_index: 0,
            rock_removal_started_date: 0,
        }
    }

    #[test]
    #[available_gas(1000000)]
    fn test_toggle_has_garden() {
        let mut player_stats = init_player_stats();
        player_stats.toggle_has_garden();
        assert(player_stats.has_garden == true, 'has_garden should be true');
        player_stats.toggle_has_garden();
        assert(player_stats.has_garden == false, 'has_garden should be false');
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
        let mut player_stats = init_player_stats();
        player_stats.start_rock_removal(1);
        player_stats.finish_rock_removal();
        assert(player_stats.rock_pending == false, 'rock_pending should be false');
        assert(player_stats.rock_pending_cell_index == 0, 'wrong rock_pending_cell_index');
        assert(player_stats.rock_removal_started_date == 0, 'wrong rock_removal_started_date');
    }
}
