use starknet::ContractAddress;

#[derive(Model, Drop, Serde)]
struct Plant {
    #[key]
    user: ContractAddress, // needed ? or link to graden ? 
    plant_type: PlantType,
    water_state: WaterState,
    growth_stage: u8, // (1 - max_for_plant_type)
    last_watered: u64,
}


trait PlantTrait {
    fn get_max_growth_level(self: Plant) -> u8;
}

impl PlantImpl of PlantTrait {
    fn get_max_growth_level(self: PlantType) -> u8 {
        match self {
            PlantType::Bamboo => 19,
            PlantType::Beet => 14,
            PlantType::Bell => 25,
            PlantType::Bulba => 20,
            PlantType::Cactus => 25,
            PlantType::Carrot => 20,
            PlantType::Chamomile => 25,
            PlantType::Corn => 25,
            PlantType::Eggplant => 25,
            PlantType::Fern => 25,
            PlantType::Lily => 25,
            PlantType::Lotus => 20,
            PlantType::Mushroom => 25,
            PlantType::Pumpkin => 25,
            PlantType::Rose => 18,
            PlantType::Salvia => 25,
            PlantType::Seaweed => 19,
            PlantType::Spike => 17,
            PlantType::Spiral => 15,
            PlantType::Sprout => 25,
            PlantType::Violet => 25,
            PlantType::Wheat => 20,
            PlantType::Zigzag => 15,
        }
    }
}


enum PlantType {
    Bamboo,
    Beet,
    Bell,
    Bulba,
    Cactus,
    Carrot,
    Chamomile,
    Corn,
    Eggplant,
    Fern,
    Lily,
    Lotus,
    Mushroom,
    Pumpkin,
    Rose,
    Salvia,
    Seaweed,
    Spike,
    Spiral,
    Sprout,
    Violet,
    Wheat,
    Zigzag,
}


#[cfg(test)]
mod tests {
    use super::{Plant, PlantImpl, PlantTrait, PlantType};
}

