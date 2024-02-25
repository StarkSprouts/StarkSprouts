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

    #[test]
    #[available_gas(1000000)]
    fn test_toggle_has_garden() {
        let mut player_stats = PlayerStats {
            player: starknet::contract_address_const::<'player'>(), has_garden: false,
        };
        player_stats.toggle_has_garden();
        assert(player_stats.has_garden == true, 'has_garden should be true');
        player_stats.toggle_has_garden();
        assert(player_stats.has_garden == false, 'has_garden should be false');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_start_rock_removal() {
        let mut player_stats = PlayerStats {
            player: starknet::contract_address_const::<'player'>(),
            has_garden: true,
            rock_pending: false,
            rock_pending_cell_index: 0,
            rock_removal_started_date: 0,
        };
        player_stats.start_rock_removal(1);
        assert(player_stats.rock_pending == true, 'rock_pending should be true');
        assert(player_stats.rock_pending_cell_index == 1, 'rock_pending_cell_index should be 1');
        assert(
            player_stats.rock_removal_started_date == starknet::get_block_timestamp,
            'rock_removal_started_date should be greater than 0'
        );
    }
}
