use starknet::{ContractAddress, get_block_timestamp};

/// @dev Plants lose 1pt of water every 30 seconds
const WATER_LOSS_RATE: u64 = 1; // 1pt per time_unit
const WATER_TIME_UNIT: u64 = 30; // 60 seconds
// @dev Time for plant to grow in seconds, and time for plant to be ready for harvest
const TIME_FOR_PLANT_TO_GROW: u64 = 120;


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
    /// Updates the water level of the plant
    fn update_water_level(ref self: Plant); //move into update growth ? 
    /// Grows the plant if it's time
    fn update_growth(ref self: Plant);
    /// Returns the max growth level for the plant type
    fn get_max_growth_level(ref self: Plant) -> u8;
    /// Harvests the plant
    fn harvest(ref self: Plant);
}

impl PlantImpl of PlantTrait {
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

    fn get_max_growth_level(ref self: Plant) -> u8 {
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

    fn water_plant(ref self: Plant) {
        self.water_level = 100;
        self.last_water_date = get_block_timestamp();
        self.update_growth();
    }


    fn update_water_level(ref self: Plant) {
        let time_since_last_water = get_block_timestamp() - self.last_water_date;
        let water_loss: u64 = (time_since_last_water / WATER_TIME_UNIT) * WATER_LOSS_RATE;

        if water_loss < self.water_level.into() {
            self.water_level -= water_loss.try_into().unwrap();
        } else {
            self.water_level = 0;
            self.is_dead = true;
        }
    }

    fn update_growth(ref self: Plant) {
        self.update_water_level();

        /// If adult plant
        let current_growth_stage = self.growth_stage;
        if current_growth_stage == self.get_max_growth_level() {
            /// If plant is ready for harvest
            let time_since_last_harvest = get_block_timestamp() - self.last_harvest_date;
            if time_since_last_harvest >= TIME_FOR_PLANT_TO_GROW {
                self.is_harvestable == true;
            }
        } /// If juvenile plant
        else {
            let time_since_planted = get_block_timestamp() - self.planted_date;
            let calculated_growth_stage = time_since_planted / TIME_FOR_PLANT_TO_GROW;
            /// Is there a change in growth stage ? 
            if calculated_growth_stage != current_growth_stage.into() {
                /// If new growth stage is less than max growth stage, update growth stage
                if calculated_growth_stage < self.get_max_growth_level().into() {
                    self.growth_stage = calculated_growth_stage.try_into().unwrap();
                } /// If new growth stage is max growth stage, update growth stage and set plant to harvestable
                else {
                    self.growth_stage = self.get_max_growth_level();
                    /// @dev Needed for logic. Without this, the plant becomes immediately harvesable after 
                    /// reaching the max growth stage, when they must wait TIME_FOR_PLANT_TO_GROW
                    self.last_harvest_date = get_block_timestamp();
                }
            }
        }
    }

    /// Update the plant's harvestable status
    fn harvest(ref self: Plant) {
        assert(self.is_harvestable, 'Plant not ready for harvest');
        self.is_harvestable = false;
        self.last_harvest_date = get_block_timestamp();
    }
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Print)]
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
    use debug::PrintTrait;
    use super::{Plant, PlantImpl, PlantTrait, PlantType};

    fn setup_plant() -> Plant {
        Plant {
            growth_stage: 1,
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
    #[ignore]
    fn test_water_plant() {
        let mut plant = setup_plant();
        plant.water_level = 50;
        /// @dev Needs to be 0 so that update growth does not sub_overflow
        plant.last_water_date = 0;
        assert(plant.water_level == 50, 'Water level should be 50');
        assert(plant.last_water_date == 111, 'Last watered time wrong');
        plant.water_plant();
        assert(plant.water_level == 100, 'Water level should be 100');
        assert(
            plant.last_water_date == 0, 'Last watered time wrong'
        ); // 0 is the current blocktime without cheatcodes
    }

    /// @dev Cannot test update_water_level or update_growth without spoofing block times

    #[test]
    #[available_gas(1000000)]
    fn test_harvest() {
        let mut plant = setup_plant();
        plant.is_harvestable = true;
        plant.harvest();
        assert(!plant.is_harvestable, 'Plant should not be harvestable');
        assert(plant.last_harvest_date == 0, 'Last harvested time wrong');
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

