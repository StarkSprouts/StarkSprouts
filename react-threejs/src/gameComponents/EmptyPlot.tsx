import { useState } from "react";
import { useDojo } from "@/dojo/useDojo";
import { PlantType } from "@/types";

export type EmptyPlotProps = {
  position: [number, number];
  cellIndex: number;
};

export const EmptyPlot = ({ position, cellIndex }: EmptyPlotProps) => {
  const {
    account: { account },
    setup: {
      systemCalls: { plantSeed },
    },
  } = useDojo();

  const [isHovered, setIsHovered] = useState(false);

  const handleEmptyCellClick = async () => {
    console.log("Empty cell clicked");

    // hardcoding plant type to 1 for now

    // choose random int from the array of plant types
    const plantTypes = [PlantType.Bell, PlantType.Sprout, PlantType.Salvia];
    const plantType = plantTypes[Math.floor(Math.random() * plantTypes.length)];

    await plantSeed(account, plantType, 0, cellIndex);
    console.log("Seed planted");
  };

  return (
    <mesh
      position={[position[0], position[1], 0]}
      onClick={handleEmptyCellClick}
      onPointerOver={() => setIsHovered(true)}
      onPointerOut={() => setIsHovered(false)}
    >
      <planeGeometry args={[1, 1]} />
      {isHovered ? (
        <meshBasicMaterial attach="material" opacity={75} />
      ) : (
        <meshBasicMaterial attach="material" transparent opacity={0} />
      )}
    </mesh>
  );
};
