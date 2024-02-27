import { useDojo } from "@/dojo/useDojo";
import { useElementStore } from "@/store";
import { Has, defineSystem } from "@dojoengine/recs";
import type { GardenCellType } from "@/types";
import { useGardenStore } from "@/stores/gardenStore";
import { useEffect } from "react";
import { GardenCellTile } from "./GardenCellTile";
import { getComponentValue } from "@dojoengine/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";

export const GardenCells = () => {
  const {
    account: { account },
    setup: {
      clientComponents: { GardenCell },
    },
  } = useDojo();

  /*
  const garden = useComponentValue(
    GardenCell,
    getEntityIdFromKeys([BigInt(account.address), BigInt(224)])
  );
  console.log("Local garden cell: ", localGardenCell);
  */

  const getAllGardenCells = () => {
    let gardenCells: GardenCellType[] = [];
    for (let i = 0; i <= 224; i++) {
      const entityId = getEntityIdFromKeys([
        BigInt(account.address),
        BigInt(i),
      ]);

      const cell = getComponentValue(GardenCell, entityId);

      gardenCells.push(cell);
    }

    return gardenCells;
  };

  const localGardenCells = getAllGardenCells();

  return (
    <>
      {
        // get all the garden cells and render them
        Object.values(localGardenCells).map((cell: GardenCellType) => {
          return <GardenCellTile key={cell.cell_index} cell={cell} />;
        })
      }
    </>
  );
};
