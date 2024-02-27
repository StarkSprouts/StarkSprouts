import { useDojo } from "@/dojo/useDojo";
import { useComponentValue } from "@dojoengine/react";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import type { GardenCellType } from "@/types";
import { getGardenPositionByCell } from "@/utils/gridHelper";

export type GardenCellProps = {
  cell: GardenCellType;
};

export const GardenCellTile = ({ cell }: GardenCellProps) => {
  const position = getGardenPositionByCell(cell.cell_index);
  console.log("Garden cell: ", cell);
  console.log("Garden cell position: ", position);

  return (
    <>
      <mesh
        position={[position[0], position[1], 0]}
        onClick={() => console.log("Garden cell clicked")}
      >
        <planeGeometry args={[1, 1]} />
        <meshBasicMaterial attach="material" color="green" />
      </mesh>
    </>
  );
};
