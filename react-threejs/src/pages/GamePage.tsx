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
import { PlantType } from "@/types";

type MenuButtonProps = {
  onPress: () => void;
  label: string;
  isActive: boolean;
};
const MenuButton = ({ onPress, label, isActive }: MenuButtonProps) => {
  return (
    <button
      onClick={onPress}
      className={`rounded-xl border-black text-xs w-20 h-5 hover:bg-gray-200 hover:border-gray-200 ${
        isActive ? "bg-blue-500" : "bg-gray-400"
      }`}
    >
      {label}
    </button>
  );
};

export default function GamePage() {
  const [width, height] = useWindowSize();
  const [loading, setLoading] = useState(true);
  const [initialized, setInitialized] = useState(false);
  const [selectedSeed, setSelectedSeed] = useState<PlantType>(PlantType.Salvia);
  const {
    account: { account },
    setup: {
      clientComponents: { GardenCell, PlayerStats },
      systemCalls: { initializeGarden, refreshGarden },
    },
  } = useDojo();

  const { playerStats, rockRemovalPending, hasGarden } = usePlayerStats();

  const handleInitGarden = async () => {
    setLoading(true);
    console.log("init world");
    await initializeGarden(account);
    setInitialized(true);
  };

  if (!playerStats || (playerStats && !hasGarden)) {
    return (
      <div className="flex w-screen h-screen justify-center items-center bg-slate-900">
        <StyledButton onPress={handleInitGarden}>Create Garden</StyledButton>
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
        <div className="absolute left-2 top-2 z-10 bg-white flex flex-col justify-center items-center space-y-1 p-2 rounded-xl">
          <div className="text-sm">Select Seed</div>
          <MenuButton
            label="Salvia"
            onPress={() => setSelectedSeed(PlantType.Salvia)}
            isActive={selectedSeed === PlantType.Salvia}
          />
          <MenuButton
            label="Bell Pepper"
            onPress={() => setSelectedSeed(PlantType.Bell)}
            isActive={selectedSeed === PlantType.Bell}
          />
          <MenuButton
            label="Sprout"
            onPress={() => setSelectedSeed(PlantType.Sprout)}
            isActive={selectedSeed === PlantType.Sprout}
          />
        </div>
        <Game canvasWidth={width} canvasHeight={height}>
          <WorldScene />
          <GardenCells selectedSeed={selectedSeed} />
        </Game>
      </div>
    </>
  );
}
