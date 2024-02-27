import { useAssets } from "./AssetLoader";

import type { AssetsType } from "./Tile";
import type { PlantType } from "@/types";

export type PlantProps = {
  plantType: PlantType;
  position: [number, number];
  cellIndex: number;
};

export const Plant = ({ plantType, position, cellIndex }: PlantProps) => {
  const { plant } = useAssets() as AssetsType;

  return (
    <mesh position={[position[0], position[1], 0]}>
      <planeGeometry args={[1, 1]} />
      <meshBasicMaterial attach="material" map={plant} transparent />
    </mesh>
  );
};
