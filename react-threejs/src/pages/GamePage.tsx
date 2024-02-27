import { Game } from "@/gameComponents/Game";
import { WorldScene } from "@/scenes/WorldScene";
import useWindowSize from "@/hooks/useWindowSize";
import { GardenCells } from "@/gameComponents/GardenCells";
import { useDojo } from "@/dojo/useDojo";
import { StyledButton } from "@/components/StyledButton";
import { useState } from "react";

export default function GamePage() {
  const [width, height] = useWindowSize();
  const [gardenInitialized, setGardenInitialized] = useState(false);
  const {
    account: { account },
    setup: {
      clientComponents: { GardenCell },
      systemCalls: { initializeGarden, refreshGarden },
    },
  } = useDojo();

  const handleInitGarden = async () => {
    console.log("init world");
    await initializeGarden(account);
    setGardenInitialized(true);
  };

  if (!gardenInitialized) {
    return (
      <div className="absolute z-10 top-5 left-2 flex flex-col space-y-2">
        <StyledButton label="Init Garden" onPress={handleInitGarden} />
      </div>
    );
  }

  return (
    <div className="flex w-screen h-screen justify-center items-center bg-slate-900">
      <Game canvasWidth={width} canvasHeight={height}>
        <WorldScene />
        <GardenCells />
      </Game>
    </div>
  );
}
