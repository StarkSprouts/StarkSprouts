use starknet::ContractAddress;
use stark_sprouts::models::water::{WaterState};

// says plants lose 1pt of water every 30 seconds
const WATER_LOSS_RATE: u64 = 1; // 1pt per time_unit
const WATER_TIME_UNIT: u64 = 30; // 60 seconds
// says plants grow 1 level every 120 seconds 
const TIME_FOR_PLANT_TO_GROW: u64 = 120; // number of seconds until a plant dies


#[derive(Copy, Drop, Serde, Introspect)]
struct Plant {
    /// The type of plant
    plant_type: PlantType,
    /// Stage of the plant's growth
    growth_stage: u8, // (0 - max_for_plant_type)
    /// Water level of the plant at the time of last watering
    water_level: u8, // (1 - 100)
    /// The time the plant was planted
    planted_at: u64,
    /// The time the plant was last watered
    last_watered: u64,
}

trait PlantTrait {
    fn get_max_growth_level(self: PlantType) -> u8;
    /// Updates the water level of the plant
    /// @dev Water level drops by WATER_LOSS_RATE every WATER_TIME_UNIT seconds
    fn update_water_level(self: Plant) -> Plant;
    /// Kills the plant
    fn kill_plant(self: Plant) -> Plant;
    /// Grows the plant amount of levels
    fn grow(self: Plant, amount: u8) -> Plant;
}

impl PlantImpl of PlantTrait {
    fn kill_plant(mut self: Plant) -> Plant {
        Plant {
            growth_stage: 0,
            water_level: 0,
            planted_at: 0,
            last_watered: 0,
            plant_type: PlantType::None,
        }
    }

    fn get_max_growth_level(self: PlantType) -> u8 {
        match self {
            PlantType::None => 0,
            PlantType::Bell => 24,
            PlantType::Bulba => 19,
            PlantType::Cactus => 24,
            PlantType::Chamomile => 24,
            PlantType::Fern => 24,
            PlantType::Lily => 24,
            PlantType::Mushroom => 24,
            PlantType::Rose => 17,
            PlantType::Salvia => 24,
            PlantType::Spiral => 14,
            PlantType::Sprout => 24,
            PlantType::Violet => 24,
            PlantType::Zigzag => 14,
        }
    }

    fn update_water_level(mut self: Plant) -> Plant {
        let time_since_last_water = starknet::get_block_timestamp() - self.last_watered;
        let water_loss = (time_since_last_water / WATER_TIME_UNIT) * WATER_LOSS_RATE;

        if water_loss < self.water_level.into() {
            self.water_level -= water_loss.try_into().unwrap();
            self
        } else {
            self.kill_plant()
        }
    }

    fn grow(mut self: Plant, amount: u8) -> Plant {
        let max_growth_level = self.plant_type.get_max_growth_level();
        let new_growth_stage = self.growth_stage + amount;

        if new_growth_stage < max_growth_level {
            self.growth_stage = new_growth_stage;
            self
        } else {
            self.growth_stage = max_growth_level;
            self
        }
    }
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
enum PlantType {
    None,
    Bell,
    Bulba,
    Cactus,
    Chamomile,
    Fern,
    Lily,
    Mushroom,
    Rose,
    Salvia,
    Spiral,
    Sprout,
    Violet,
    Zigzag,
}


#[cfg(test)]
mod tests {
    use super::{Plant, PlantImpl, PlantTrait, PlantType};

    fn setup_plant() -> Plant {
        Plant {
            growth_stage: 0,
            water_level: 100,
            planted_at: 111,
            last_watered: 222,
            plant_type: PlantType::Zigzag,
        }
    }

    #[test]
    #[available_gas(1000000)]
    fn test_grow() {
        let mut i = 0;
        let mut plant = setup_plant();
        loop {
            if i >= plant.plant_type.get_max_growth_level() + 5 {
                break;
            }
            plant = plant.grow();
            i += 1;
        };

        assert(
            plant.growth_stage == plant.plant_type.get_max_growth_level(),
            'Plant should be fully grown'
        );
    }
}

