import { Button } from "../components/ui/button";
import { useDojo } from "@/dojo/useDojo";
import type { Account } from "starknet";

export default function TestPage() {
  const {
    setup: {
      systemCalls: {
        initializeGarden,
        refreshGarden,
        removeRock,
        removeDeadPlant,
        waterPlant,
        plantSeed,
        harvestPlant,
      },
      clientComponents: { GardenCell },
    },
    account: { account },
  } = useDojo();

  const handleInitGarden = () => {
    console.log("Init World");
    initializeGarden(account);
  };
  const handleRemoveRock = () => {
    console.log("Remove Rock");
  };
  const handleRemoveDeadPlant = () => {
    console.log("Remove Dead Plant");
  };
  const handleWaterPlant = () => {
    console.log("Water Plant");
  };
  const handlePlantSeed = () => {
    console.log("Plant Seed");
    plantSeed(account, 1, 2, 3);
  };
  const handleHarvestPlant = () => {
    console.log("Harvest Plant");
  };

  return (
    <div className="relative w-screen h-screen flex flex-col">
      <main className="flex flex-col left-0 relative top-0 overflow-hidden grow">
        <div>
          <Button label="Init World" onPress={handleInitGarden} />
          <Button label="Remove Rock" onPress={handleRemoveRock} />
          <Button label="Remove Dead Plant" onPress={handleRemoveDeadPlant} />
          <Button label="Water Plant" onPress={handleWaterPlant} />
          <Button label="Plant Seed" onPress={handlePlantSeed} />
          <Button label="Harvest Plant" onPress={handleHarvestPlant} />
        </div>
      </main>
    </div>
  );
}
