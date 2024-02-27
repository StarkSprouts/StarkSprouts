import { useAssets } from "./AssetLoader";
import { AssetsType } from "./AssetLoader";

export type SoilProps = {
  waterLevel: number;
  position: [number, number];
};

export const Soil = ({ waterLevel, position }: SoilProps) => {
  const { plot } = useAssets() as AssetsType;

  let color;
  if (waterLevel >= 0 && waterLevel < 20) {
    color = "#FFB464";
  } else if (waterLevel >= 20 && waterLevel < 40) {
    color = "#ED9352";
  } else if (waterLevel >= 40 && waterLevel < 60) {
    color = "#DA874C";
  } else if (waterLevel >= 60 && waterLevel < 80) {
    color = "#BB6D3E";
  } else if (waterLevel >= 80 && waterLevel <= 100) {
    color = "#905424";
  } else {
    color = null;
  }

  return (
    <mesh position={[position[0], position[1], 0]}>
      <planeGeometry args={[1, 1]} />
      {color ? (
        <meshBasicMaterial
          attach="material"
          color={color}
          opacity={75}
          blendColor={color}
        />
      ) : (
        <meshBasicMaterial attach="material" map={plot} />
      )}
    </mesh>
  );
};
