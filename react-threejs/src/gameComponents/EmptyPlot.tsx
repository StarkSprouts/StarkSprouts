import { useState } from "react";
import { useDojo } from "@/dojo/useDojo";
import { PlantType } from "@/types";

export type EmptyPlotProps = {
  position: [number, number];
  cellIndex: number;
  selectedSeed: PlantType;
};

export const EmptyPlot = ({
  position,
  cellIndex,
  selectedSeed,
}: EmptyPlotProps) => {
  const {
    account: { account },
    setup: {
      systemCalls: { plantSeed },
    },
  } = useDojo();

  const [isHovered, setIsHovered] = useState(false);

  const handleEmptyCellClick = async () => {
    console.log("Empty cell clicked");

    await plantSeed(account, selectedSeed, 0, cellIndex);
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
