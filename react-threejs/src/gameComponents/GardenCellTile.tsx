import { useDojo } from "@/dojo/useDojo";
import { useComponentValue } from "@dojoengine/react";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import type { GardenCellType } from "@/types";
import { getGardenPositionByCell } from "@/utils/gridHelper";
import { Plant } from "@/gameComponents/Plant";
import { Rock } from "@/gameComponents/Rock";
import { EmptyPlot } from "./EmptyPlot";
import { PlantType } from "@/types";

export type GardenCellProps = {
  cell: GardenCellType;
  selectedSeed: PlantType;
};

export const GardenCellTile = ({ cell, selectedSeed }: GardenCellProps) => {
  const position = getGardenPositionByCell(cell.cell_index);
  //console.log("cell", cell);

  if (cell.plant.plant_type) {
    console.log("plant", cell.plant.plant_type);
    return (
      <Plant
        key={cell.cell_index}
        plantType={cell.plant.plant_type}
        position={[position[0], position[1]]}
        cellIndex={cell.cell_index}
        growthStage={cell.plant.growth_stage}
        isDead={cell.plant.is_dead}
        // add a background color to represent the water level
      />
    );
  }

  if (cell.has_rock) {
    return (
      <Rock
        key={cell.cell_index}
        position={[position[0], position[1]]}
        cellIndex={cell.cell_index}
      />
    );
  }

  return (
    <EmptyPlot
      key={cell.cell_index}
      position={[position[0], position[1]]}
      cellIndex={cell.cell_index}
      selectedSeed={selectedSeed}
    />
  );
};
