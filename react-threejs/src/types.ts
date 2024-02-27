export enum PlantType {
  None = 0,
  Bell = 1,
  Bulba = 2,
  Cactus = 3,
  Chamomile = 4,
  Fern = 5,
  Lily = 6,
  Mushroom = 7,
  Rose = 8,
  Salvia = 9,
  Spiral = 10,
  Sprout = 11,
  Violet = 12,
  Zigzag = 13,
}

export type GardenCellType = {
  player_address: BigInt;
  cell_index: number;
  has_rock: boolean;
  plant: {
    plant_type: PlantType;
    water_level: number;
    growth_stage: number;
    planted_at: number;
    last_watered: number;
  };
};
