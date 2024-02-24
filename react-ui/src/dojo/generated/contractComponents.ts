// NOTE: this file should be generated in the future but right now it's manually created

// @ts-ignore:
import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export type ContractComponents = Awaited<
  ReturnType<typeof defineContractComponents>
>;

enum PlantType {}

export interface Plant {
  plant_type: PlantType;
  growth_stage: number; // (0 - max_for_plant_type)
  water_level: number; // (1 - 100)
  planted_at: number;
  last_watered: number;
}

export const PlantDefinition = {
  plant_type: RecsType.Number,
  growth_stage: RecsType.Number,
  water_level: RecsType.Number,
  planted_at: RecsType.Number,
  last_watered: RecsType.Number,
};

export function defineContractComponents(world: World) {
  return {
    GardenCell: (() => {
      return defineComponent(
        world,
        {
          player_address: RecsType.BigInt,
          cell_index: RecsType.Number,
          has_rock: RecsType.Boolean,
          plant: PlantDefinition,
        },
        {
          metadata: {
            name: "Plant",
            types: ["ContractAddress", "u16", "bool", "Plant"],
            customTypes: ["Plant"],
          },
        }
      );
    })(),
  };
}
