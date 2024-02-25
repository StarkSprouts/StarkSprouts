import { Button } from "../components/ui/button";
import { useDojo } from "@/dojo/useDojo";
import type { Account } from "starknet";

export default function TestPage() {
  const {
    setup: {
      systemCalls: {
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

  const handleInitWorld = () => {
    console.log("Init World");
    refreshGarden(account);
  };
  const handleRemoveRock = () => {
    console.log("Remove Rock");
  };
  const handleRemoveDeadPlant = () => {
    console.log("Remove Dead Plant");
  };
  const handleWaterPlants = () => {
    console.log("Water Plants");
  };
  const handlePlantSeeds = () => {
    console.log("Plant Seeds");
  };
  const handleHarvestPlants = () => {
    console.log("Harvest Plants");
  };

  return (
    <div className="relative w-screen h-screen flex flex-col">
      <main className="flex flex-col left-0 relative top-0 overflow-hidden grow">
        <div>
          <Button label="Init World" onPress={handleInitWorld} />
          <Button label="Remove Rock" onPress={handleRemoveRock} />
          <Button label="Remove Dead Plant" onPress={handleRemoveDeadPlant} />
          <Button label="Water Plants" onPress={handleWaterPlants} />
          <Button label="Plant Seeds" onPress={handlePlantSeeds} />
          <Button label="Harvest Plants" onPress={handleHarvestPlants} />
        </div>
      </main>
    </div>
  );
}
