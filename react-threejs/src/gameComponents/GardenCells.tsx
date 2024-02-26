import { useDojo } from "@/dojo/useDojo";
import { useElementStore } from "@/store";
import { Has, defineSystem } from "@dojoengine/recs";
import type { GardenCellType } from "@/types";
import { useGardenStore } from "@/stores/gardenStore";
import { useEffect } from "react";
import { GardenCellTile } from "./GardenCellTile";
import { getComponentValue } from "@dojoengine/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";

export const GardenCells = (gardenCells: GardenCellType[]) => {
  //const gardenCells = useGardenStore((state) => state.gardenCells);
  //console.log("Gaden cells: ", JSON.stringify(gardenCells, null, 2));
  //const setGardenCells = useGardenStore((state) => state.setGardenCells);

  console.log("Garden cells component: ", JSON.stringify(gardenCells, null, 2));

  /*
  useEffect(() => {
    const loadGraden = async (account) => {
      await refreshGarden(account);
      const gardenCells = getComponentValue(
        GardenCell,
        getEntityIdFromKeys([BigInt(account.address)])
      );
      console.log("Garden cells: ", JSON.stringify(gardenCells, null, 2));
    };

    loadGraden(account);
  }, [account]);
  */

  /*
  useEffect(() => {
    defineSystem(
      world,
      [Has(GardenCell)],
      (entity) =>
        ({ value: [newValue] }) => {
          setGardenCells(newValue);
        }
    );
  }, []);
  */

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
