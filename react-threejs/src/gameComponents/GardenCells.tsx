import { useDojo } from "@/dojo/useDojo";
import { useElementStore } from "@/store";
import { Has, defineSystem } from "@dojoengine/recs";
import type { GardenCellType } from "@/types";
import { useGardenStore } from "@/stores/gardenStore";
import { useEffect, useState } from "react";
import { GardenCellTile } from "./GardenCellTile";
import { getComponentValue } from "@dojoengine/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";

export const GardenCells = () => {
  const [gardenCells, setGardenCells] = useState<GardenCellType[]>([]);
  const {
    account: { account },
    setup: {
      clientComponents: { GardenCell },
    },
  } = useDojo();

  useEffect(() => {
    const getAllGardenCells = () => {
      let cells: GardenCellType[] = [];
      for (let i = 0; i <= 224; i++) {
        const entityId = getEntityIdFromKeys([
          BigInt(account.address),
          BigInt(i),
        ]);

        const cell = getComponentValue(GardenCell, entityId);

        cells.push(cell);
      }

      setGardenCells(cells);
    };

    getAllGardenCells();
  }, [account]);

  if (gardenCells.length === 0) {
    return null;
  }
  return (
    <>
      {
        // get all the garden cells and render them
        Object.values(gardenCells).map((cell: GardenCellType) => {
          return <GardenCellTile key={cell.cell_index} cell={cell} />;
        })
      }
    </>
  );
};
