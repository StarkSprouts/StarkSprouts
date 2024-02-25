use starknet::ContractAddress;

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
    /// Wipes the plant's data
    fn reset(ref self: Plant);
    /// Returns the max growth level for the plant
    fn get_max_growth_level(ref self: PlantType) -> u8;
    /// Asserts that the plant is dead
    fn assert_dead(ref self: Plant);
    /// Asserts that the plant is alive
    fn assert_alive(ref self: Plant);

    /// Top off the plants water level
    fn water_plant(ref self: Plant);

    /// Updates the water level of the plant
    fn update_water_level(ref self: Plant);

    /// Grows the plant amount of levels
    fn grow(ref self: Plant, amount: u8);
}

impl PlantImpl of PlantTrait {
    fn reset(ref self: Plant) {
        self.plant_type = PlantType::None;
        self.growth_stage = 0;
        self.water_level = 0;
        self.planted_at = 0;
        self.last_watered = 0;
    }

    fn assert_dead(ref self: Plant) {
        assert(self.plant_type == PlantType::Dead, 'Plant is alive');
    }

    fn assert_alive(ref self: Plant) {
        assert(self.plant_type != PlantType::Dead, 'Plant is dead');
    }

    fn water_plant(ref self: Plant) {
        self.water_level = 100;
        self.last_watered = starknet::get_block_timestamp();
    }

    fn get_max_growth_level(ref self: PlantType) -> u8 {
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
            PlantType::Dead => 0,
        }
    }

    fn update_water_level(ref self: Plant) {
        let time_since_last_water = starknet::get_block_timestamp() - self.last_watered;
        let water_loss: u64 = (time_since_last_water / WATER_TIME_UNIT) * WATER_LOSS_RATE;
        let current_water_level: u8 = self.water_level;

        if water_loss < current_water_level.into() {
            self.water_level -= water_loss.try_into().unwrap();
        } else {
            self.plant_type = PlantType::Dead;
        }
    }

    fn grow(ref self: Plant, amount: u8) {
        self.assert_alive();
        let max_growth_level = self.plant_type.get_max_growth_level();
        let new_growth_stage = self.growth_stage + amount;

        if new_growth_stage < max_growth_level {
            self.growth_stage = new_growth_stage;
        } else {
            self.growth_stage = max_growth_level;
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
    Dead,
}

impl PlantTypeIntoFelt252 of Into<PlantType, felt252> {
    fn into(self: PlantType) -> felt252 {
        match self {
            PlantType::None => 0,
            PlantType::Bell => 1,
            PlantType::Bulba => 2,
            PlantType::Cactus => 3,
            PlantType::Chamomile => 4,
            PlantType::Fern => 5,
            PlantType::Lily => 6,
            PlantType::Mushroom => 7,
            PlantType::Rose => 8,
            PlantType::Salvia => 9,
            PlantType::Spiral => 10,
            PlantType::Sprout => 11,
            PlantType::Violet => 12,
            PlantType::Zigzag => 13,
            PlantType::Dead => 0,
        }
    }
}

impl Felt252IntoPlantType of Into<felt252, PlantType> {
    fn into(self: felt252) -> PlantType {
        match self {
            0 => PlantType::None,
            1 => PlantType::Bell,
            2 => PlantType::Bulba,
            3 => PlantType::Cactus,
            4 => PlantType::Chamomile,
            5 => PlantType::Fern,
            6 => PlantType::Lily,
            7 => PlantType::Mushroom,
            8 => PlantType::Rose,
            9 => PlantType::Salvia,
            10 => PlantType::Spiral,
            11 => PlantType::Sprout,
            12 => PlantType::Violet,
            13 => PlantType::Zigzag,
            _ => PlantType::None,
        }
    }
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

