import { Game } from "@/gameComponents/Game";
import { WorldScene } from "@/scenes/WorldScene";
import useWindowSize from "@/hooks/useWindowSize";
import { GardenCells } from "@/gameComponents/GardenCells";
import { useDojo } from "@/dojo/useDojo";
import { StyledButton } from "@/components/StyledButton";
import { useState } from "react";
import { useEffect } from "react";
import {
  getEntityIdFromKeys,
  parseComponentValueFromGraphQLEntity,
} from "@dojoengine/utils";
import { getComponentValue } from "@dojoengine/recs";
import type { PlayerStatsType } from "@/types";
import { usePlayerStats } from "@/hooks/usePlayerStats";

export default function GamePage() {
  const [width, height] = useWindowSize();
  const [loading, setLoading] = useState(true);
  const [initialized, setInitialized] = useState(false);
  const {
    account: { account },
    setup: {
      clientComponents: { GardenCell, PlayerStats },
      systemCalls: { initializeGarden, refreshGarden },
    },
  } = useDojo();

  const { playerStats, rockRemovalPending, hasGarden } = usePlayerStats();

  const handleInitGarden = async () => {
    console.log("init world");
    await initializeGarden(account);
    setInitialized(true);
  };

  if (!playerStats || (playerStats && !hasGarden)) {
    return (
      <div className="flex w-screen h-screen justify-center items-center bg-slate-900">
        <StyledButton onPress={handleInitGarden}>
          Initialize Garden
        </StyledButton>
      </div>
    );
  }

  return (
    <>
      {rockRemovalPending[0] && (
        <div className="fixed bottom-0 left-0 right-0 p-4 text-white z-10">
          <p>Removing rock...</p>
        </div>
      )}
      <div className="flex w-screen h-screen justify-center items-center bg-slate-900">
        <Game canvasWidth={width} canvasHeight={height}>
          <WorldScene />
          <GardenCells />
        </Game>
      </div>
    </>
  );
}
