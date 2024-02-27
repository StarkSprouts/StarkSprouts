import { useDojo } from "@/dojo/useDojo";
import { useComponentValue } from "@dojoengine/react";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import type { GardenCellType } from "@/types";
import { getGardenPositionByCell } from "@/utils/gridHelper";
import { Plant } from "@/gameComponents/Plant";
import { Rock } from "@/gameComponents/Rock";
import { EmptyPlot } from "./EmptyPlot";
import { PlantType } from "@/types";
import { Soil } from "./Soil";

export type GardenCellProps = {
  cell: GardenCellType;
  selectedSeed: PlantType;
};

export const GardenCellTile = ({ cell, selectedSeed }: GardenCellProps) => {
  const position = getGardenPositionByCell(cell.cell_index);
  //console.log("cell", cell);

  if (cell.plant.plant_type) {
    console.log("PLANT", cell);
    return (
      <>
        <Plant
          key={`${cell.cell_index}-plant`}
          plantType={cell.plant.plant_type}
          position={[position[0], position[1]]}
          cellIndex={cell.cell_index}
          growthStage={cell.plant.growth_stage}
          isDead={cell.plant.is_dead}
        />
        <Soil
          key={`${cell.cell_index}-soil`}
          position={[position[0], position[1]]}
          waterLevel={cell.plant.water_level}
        />
      </>
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
