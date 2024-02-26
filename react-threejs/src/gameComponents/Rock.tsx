import { useAssets } from "./AssetLoader";

import type { AssetsType } from "./Tile";

export const Rock = () => {
  const { rock } = useAssets() as AssetsType;

  return (
    <mesh position={[0, 0, 0]}>
      <planeBufferGeometry args={[1, 1]} />
      <meshBasicMaterial attach="material" map={rock} />
    </mesh>
  );
};
