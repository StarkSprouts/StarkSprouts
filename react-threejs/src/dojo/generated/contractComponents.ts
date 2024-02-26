// NOTE: this file should be generated in the future but right now it's manually created

// @ts-ignore:
import { defineComponent, Type as RecsType, World } from "@dojoengine/recs";

export type ContractComponents = Awaited<
  ReturnType<typeof defineContractComponents>
>;

enum PlantType {}

export interface Plant {
  plant_type: PlantType;
  is_dead: boolean;
  is_harvestable: boolean;
  growth_stage: number;
  water_level: number;
  planted_date: number;
  last_water_date: number;
  last_harvest_date: number;
}

export const PlantDefinition = {
  plant_type: RecsType.Number,
  is_dead: RecsType.Boolean,
  is_harvestable: RecsType.Boolean,
  growth_stage: RecsType.Number,
  water_level: RecsType.Number,
  planted_date: RecsType.Number,
  last_water_date: RecsType.Number,
  last_harvest_date: RecsType.Number,
};

export function defineContractComponents(world: World) {
  return {
    GardenCell: (() => {
      return defineComponent(
        world,
        {
          player: RecsType.BigInt,
          cell_index: RecsType.Number,
          has_rock: RecsType.Boolean,
          plant: PlantDefinition,
        },
        {
          metadata: {
            name: "GardenCell",
            types: ["contractaddress", "u16", "bool", "struct"],
            customTypes: ["Plant"],
          },
        }
      );
    })(),
  };
}
