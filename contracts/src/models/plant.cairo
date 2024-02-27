use starknet::{ContractAddress, get_block_timestamp};
use debug::PrintTrait;
use stark_sprouts::systems::{actions::{actions, IActionsDispatcher, IActionsDispatcherTrait}};

/// @dev Plants lose 1pt of water every 30 seconds
const WATER_LOSS_RATE: u64 = 1; // 1pt per time_unit
const WATER_TIME_UNIT: u64 = 1;
// @dev Time for plant to grow in seconds, and time for plant to be ready for harvest
const TIME_FOR_PLANT_TO_GROW: u64 = 3;


#[derive(Copy, Drop, Serde, Introspect)]
struct Plant {
    /// The type of plant
    plant_type: PlantType,
    /// Is the plant dead  
    is_dead: bool,
    /// Is the plant ready for harvest
    is_harvestable: bool,
    /// Stage of the plant's growth, [0, max_for_plant_type]
    growth_stage: u8,
    /// Water level of the plant
    water_level: u8, // (1 - 100)
    /// The time the plant was planted
    planted_date: u64,
    /// The time the plant was last watered
    last_water_date: u64,
    /// The time the plant was last harvested
    last_harvest_date: u64,
}

trait PlantTrait {
    /// Sets the plant to default values
    fn reset(ref self: Plant);
    /// Top off the plants water level
    fn water_plant(ref self: Plant);
    /// Plant loses water over time
    fn lose_water(ref self: Plant);
    /// Grows the plant if it's time
    fn update_growth(ref self: Plant);
    /// Returns the max growth level for the plant type
    fn get_max_growth_level(self: @Plant) -> u8;
    /// Harvest the plant if it's ready
    fn harvest(ref self: Plant);
}

impl PlantImpl of PlantTrait {
    /// Sets the plant to default values
    fn reset(ref self: Plant) {
        self =
            Plant {
                plant_type: PlantType::None,
                is_dead: false,
                growth_stage: 0,
                water_level: 0,
                planted_date: 0,
                last_water_date: 0,
                last_harvest_date: 0,
                is_harvestable: false,
            };
    }

    /// Returns the max growth level for the plant type
    fn get_max_growth_level(self: @Plant) -> u8 {
        match self.plant_type {
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

    /// Top off the plants water level
    fn water_plant(ref self: Plant) {
        self.update_growth();

        if self.is_dead {
            return;
        }

        self.water_level = 100; /// moved from below, 
        self.last_water_date = get_block_timestamp();
    }

    /// Plant loses water over time
    fn lose_water(ref self: Plant) {
        assert(self.plant_type != PlantType::None, 'No plant here');
        assert(!self.is_dead, 'Plant is dead');

        let time_since_last_water = get_block_timestamp() - self.last_water_date;
        let water_loss: u64 = (time_since_last_water / WATER_TIME_UNIT) * WATER_LOSS_RATE;

        if water_loss < self.water_level.into() {
            self.water_level -= water_loss.try_into().unwrap();
            self.last_water_date = get_block_timestamp();
        } else {
            self.water_level = 0;
            self.is_dead = true;
        }
    }

    /// Updates plant's state based on time since last interaction
    fn update_growth(ref self: Plant) {
        /// Plant loses water over time
        self.lose_water();

        let current_growth_stage = self.growth_stage;
        let max_growth_stage = self.get_max_growth_level();
        /// If plant is dead, no need to update growth
        if self.is_dead {
            return;
        } /// If adult plant, 

        /// update growth here then handle 

        let mut calculated_growth_stage = (get_block_timestamp() - self.planted_date)
            / TIME_FOR_PLANT_TO_GROW;

        // if calculated_growth_stage > max_growth_stage.into() {
        //     calculated_growth_stage = max_growth_stage.into();
        // }

        if current_growth_stage == max_growth_stage {
            // If plant just became an adult,
            if self.last_harvest_date == 0 {
                self.last_harvest_date = get_block_timestamp();
            } /// Been an adult, check if it's harvestable
            else {
                let time_since_last_harvest = get_block_timestamp() - self.last_harvest_date;
                if time_since_last_harvest >= actions::TIME_FOR_PLANT_TO_HARVEST {
                    self.is_harvestable = true;
                }
            }
        } /// If juvenile plant, calculate is growth stage from birth
        else {
            /// How old is the plant 
            let time_since_planted = get_block_timestamp() - self.planted_date;
            /// What growth stage should the plant be at
            let mut calculated_growth_stage = time_since_planted / TIME_FOR_PLANT_TO_GROW;
            /// @dev Limit growth stage to max 
            if calculated_growth_stage > max_growth_stage.into() {
                calculated_growth_stage = max_growth_stage.into();
            }
            /// Is there any changes to the growth stage
            if calculated_growth_stage != current_growth_stage.into() {
                /// Update growth stage
                self.growth_stage = calculated_growth_stage.try_into().unwrap();

                if calculated_growth_stage == max_growth_stage.into() {
                    self.last_harvest_date = get_block_timestamp();
                }
            }
        }
    }

    /// Harvest the plant if it's ready
    fn harvest(ref self: Plant) {
        assert(self.is_harvestable, 'Plant not ready for harvest');
        self.is_harvestable = false;
        self.last_harvest_date = get_block_timestamp();
    }
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)] // Print
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
    use starknet::testing::{set_block_timestamp};
    use starknet::get_block_timestamp;
    use debug::PrintTrait;
    use super::{Plant, PlantImpl, PlantTrait, PlantType};

    fn setup_plant() -> Plant {
        Plant {
            growth_stage: 0,
            water_level: 100,
            planted_date: 111,
            last_water_date: 222,
            plant_type: PlantType::Zigzag,
            is_dead: false,
            last_harvest_date: 0,
            is_harvestable: false,
        }
    }

    #[test]
    #[available_gas(1000000)]
    fn test_plant_reset() {
        let mut plant = setup_plant();
        plant.reset();
        assert(plant.growth_stage == 0, 'Growth stage should be 0');
        assert(plant.water_level == 0, 'Water level should be 0');
        assert(plant.planted_date == 0, 'Planted at should be 0');
        assert(plant.last_water_date == 0, 'Last watered should be 0');
        assert(plant.plant_type == PlantType::None, 'Plant type should be None');
        assert(!plant.is_dead, 'Plant should be alive');
        assert(plant.last_harvest_date == 0, 'Last harvested should be 0');
        assert(!plant.is_harvestable, 'Plant should not be harvestable');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_water_plant() {
        let mut plant = timed_plant();
        plant.water_level = 50;
        assert(plant.water_level == 50, 'Water level should be 50');
        plant.water_plant();
        assert(plant.water_level == 100, 'Water level should be 100');
    }

    fn timed_plant() -> Plant {
        set_block_timestamp(0xfff);
        Plant {
            growth_stage: 0,
            water_level: 100,
            planted_date: get_block_timestamp(),
            last_water_date: get_block_timestamp(),
            plant_type: PlantType::Zigzag,
            is_dead: false,
            last_harvest_date: 0,
            is_harvestable: false,
        }
    }

    #[test]
    #[available_gas(1000000)]
    fn test_lose_water() {
        set_block_timestamp(0xfff);

        let mut plant = timed_plant();
        assert(plant.water_level == 100, 'Water level should be 100');

        set_block_timestamp(get_block_timestamp() + 2);
        plant.lose_water();
        assert(plant.water_level == 98, 'Water level should be 99');

        set_block_timestamp(get_block_timestamp() + 8);
        plant.lose_water();
        assert(plant.water_level == 90, 'Water level should be 96');

        set_block_timestamp(get_block_timestamp() + 90);
        plant.lose_water();
        assert(plant.water_level == 0, 'Water level should be 0');
        assert(plant.is_dead, 'Plant should be dead');
    }

    #[test]
    #[available_gas(10000000)]
    fn test_update_growth_level_to_harvest_and_beyond() {
        let mut plant = timed_plant();

        let max_growth_level = plant.get_max_growth_level();
        let time_to_grow = 3;
        let time_to_harvest = 5;

        assert(plant.growth_stage == 0, 'Growth stage should be 0');
        assert(plant.last_harvest_date == 0, 'Last harvested time wrong0');
        // plant.update_growth();

        // set_block_timestamp(get_block_timestamp() + time_to_grow);
        // plant.update_growth();
        // assert(plant.growth_stage == 1, 'Growth stage should be 1');

        // set_block_timestamp(get_block_timestamp() + time_to_grow + time_to_grow);
        // plant.update_growth();
        // assert(plant.growth_stage == 3, 'Growth stage should be 3');

        // set_block_timestamp(get_block_timestamp() + time_to_grow - 1);
        // plant.update_growth();
        // assert(plant.growth_stage == 3, 'Growth stage should be 3');
        // set_block_timestamp(get_block_timestamp() + 1);
        // plant.update_growth();

        loop {
            set_block_timestamp(get_block_timestamp() + time_to_grow);
            plant.water_plant();
            if plant.growth_stage == max_growth_level {
                break;
            }
        };

        assert(plant.growth_stage == max_growth_level, 'Growth stage should be max');
        assert(!plant.is_harvestable, 'Should not be harvestable1');
        assert(plant.last_harvest_date == get_block_timestamp(), 'Last harvested time wrong1');

        set_block_timestamp(get_block_timestamp() + time_to_harvest - 1);
        plant.water_plant();
        assert(!plant.is_harvestable, 'Should not be harvestable2');

        set_block_timestamp(get_block_timestamp() + 1);
        plant.water_plant();
        assert(plant.is_harvestable, 'Should be harvestable3');

        set_block_timestamp(get_block_timestamp() + 5);
        plant.water_plant();
        plant.harvest();
        assert(!plant.is_harvestable, 'Should not be harvestable4');
        assert(plant.last_harvest_date == get_block_timestamp(), 'Last harvested time wrong2');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_get_max_growth_level() {
        let mut plant = setup_plant();
        plant.plant_type = PlantType::None;
        assert(plant.get_max_growth_level() == 0, 'Max growth level should be 0');
        plant.plant_type = PlantType::Bell;
        assert(plant.get_max_growth_level() == 24, 'Max growth level should be 24');
        plant.plant_type = PlantType::Bulba;
        assert(plant.get_max_growth_level() == 19, 'Max growth level should be 19');
        plant.plant_type = PlantType::Cactus;
        assert(plant.get_max_growth_level() == 24, 'Max growth level should be 24');
        plant.plant_type = PlantType::Chamomile;
        assert(plant.get_max_growth_level() == 24, 'Max growth level should be 24');
        plant.plant_type = PlantType::Fern;
        assert(plant.get_max_growth_level() == 24, 'Max growth level should be 24');
        plant.plant_type = PlantType::Lily;
        assert(plant.get_max_growth_level() == 24, 'Max growth level should be 24');
        plant.plant_type = PlantType::Mushroom;
        assert(plant.get_max_growth_level() == 24, 'Max growth level should be 24');
        plant.plant_type = PlantType::Rose;
        assert(plant.get_max_growth_level() == 17, 'Max growth level should be 17');
        plant.plant_type = PlantType::Salvia;
        assert(plant.get_max_growth_level() == 24, 'Max growth level should be 24');
        plant.plant_type = PlantType::Spiral;
        assert(plant.get_max_growth_level() == 14, 'Max growth level should be 14');
        plant.plant_type = PlantType::Sprout;
        assert(plant.get_max_growth_level() == 24, 'Max growth level should be 24');
        plant.plant_type = PlantType::Violet;
        assert(plant.get_max_growth_level() == 24, 'Max growth level should be 24');
        plant.plant_type = PlantType::Zigzag;
        assert(plant.get_max_growth_level() == 14, 'Max growth level should be 14');
    }
}
