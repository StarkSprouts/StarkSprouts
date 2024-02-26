import { Game } from "@/gameComponents/Game";
import { WorldScene } from "@/scenes/WorldScene";
import useWindowSize from "@/hooks/useWindowSize";
import { Plant } from "@/gameComponents/Plant";
import { GardenCells } from "@/gameComponents/GardenCells";
import { useDojo } from "@/dojo/useDojo";
import { StyledButton } from "@/components/StyledButton";
import { getComponentValue } from "@dojoengine/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { GardenCellType } from "@/types";
import { useState } from "react";
import { useComponentValue } from "@dojoengine/react";

export default function GamePage() {
  const [width, height] = useWindowSize();
  const [gardenCells, setGardenCells] = useState<GardenCellType[]>([]); // [GardenCellType
  const {
    account: { account },
    setup: {
      clientComponents: { GardenCell },
      systemCalls: { initializeGarden, refreshGarden },
    },
  } = useDojo();

  const localGardenCell = useComponentValue(
    GardenCell,
    getEntityIdFromKeys([BigInt(account.address)])
  );
  console.log("Local garden cell: ", JSON.stringify(localGardenCell));

  const handleInitGarden = () => {
    console.log("init world");
    initializeGarden(account);
  };

  const handleRefreshGarden = async () => {
    if (!account) {
      return;
    }
    console.log(`Account: ${account.address}`);
    console.log("refresh world");
    await refreshGarden(account);
    const cells = getComponentValue(
      GardenCell,
      getEntityIdFromKeys([BigInt(account.address)])
    );
    console.log("Garden cells: ", JSON.stringify(cells, null, 2));
    if (cells) {
      setGardenCells(cells);
    }
  };

  return (
    <div className="flex w-screen h-screen justify-center items-center bg-slate-900">
      <div className="absolute z-10 top-10 bg-slate-500">
        <StyledButton label="Init Garden" onPress={handleInitGarden} />
        <StyledButton label="Refresh Garden" onPress={handleRefreshGarden} />
      </div>
      <Game canvasWidth={width} canvasHeight={height}>
        <WorldScene />
        <GardenCells gardenCells={gardenCells} />
      </Game>
    </div>
  );
}
