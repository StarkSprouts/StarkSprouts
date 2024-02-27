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
  const {
    account: { account },
    setup: {
      clientComponents: { GardenCell },
      systemCalls: { initializeGarden, refreshGarden },
    },
  } = useDojo();

  const handleInitGarden = () => {
    console.log("init world");
    initializeGarden(account);
  };

  const handleRefreshGarden = async () => {
    console.log("refresh world");
    refreshGarden(account);
  };

  return (
    <div className="flex w-screen h-screen justify-center items-center bg-slate-900">
      <div className="absolute z-10 top-10 bg-slate-500">
        <StyledButton label="Init Garden" onPress={handleInitGarden} />
        <StyledButton label="Refresh Garden" onPress={handleRefreshGarden} />
      </div>
      <Game canvasWidth={width} canvasHeight={height}>
        <WorldScene />
        <GardenCells />
      </Game>
    </div>
  );
}
