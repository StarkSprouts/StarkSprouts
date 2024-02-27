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
      systemCalls: { refreshGarden },
    },
  } = useDojo();

  useEffect(() => {
    const getAllGardenCells = async () => {
      // refresh the garden cells before rendering them
      await refreshGarden(account);

      let cells: GardenCellType[] = [];
      for (let i = 0; i <= 224; i++) {
        const entityId = getEntityIdFromKeys([
          BigInt(account.address),
          BigInt(i),
        ]);

        const cell = getComponentValue(GardenCell, entityId);

        // @ts-ignore
        cells.push(cell);
      }

      setGardenCells(cells);
    };

    getAllGardenCells();

    // refetch all the garden cells periodically
    // NOTE: this is not a good way to do this, but it's fine for now
    const interval = setInterval(() => {
      getAllGardenCells();
    }, 3000);
    return () => clearInterval(interval);
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
