import { useAssets } from "./AssetLoader";

import type { AssetsType } from "./Tile";

export type RockProps = {
  position: [number, number];
};

export const Rock = ({ position }: RockProps) => {
  // TODO: Add a rock asset
  //const { rock } = useAssets() as AssetsType;

  return (
    <mesh position={[position[0], position[1], 0]}>
      <planeGeometry args={[1, 1]} />
      <meshBasicMaterial attach="material" color="black" />
    </mesh>
  );
};
