import { useAssets } from "./AssetLoader";
import { AssetsType } from "./AssetLoader";

import { PlantType } from "@/types";

export type PlantProps = {
  plantType: PlantType;
  position: [number, number];
  cellIndex: number;
  growthStage: number;
};

const getBellTextureByGrowthStage = (
  growthStage: number,
  plantTextures: AssetsType
) => {
  // TODO: make this better. This is disgusting
  console.log("growthStage", growthStage);
  switch (growthStage) {
    case 0:
      return plantTextures.bell0;
    case 1:
      return plantTextures.bell1;
    case 2:
      return plantTextures.bell2;
    case 3:
      return plantTextures.bell3;
    case 4:
      return plantTextures.bell4;
    case 5:
      return plantTextures.bell5;
    case 6:
      return plantTextures.bell6;
    case 7:
      return plantTextures.bell7;
    case 8:
      return plantTextures.bell8;
    case 9:
      return plantTextures.bell9;
    case 10:
      return plantTextures.bell10;
    case 11:
      return plantTextures.bell11;
    case 12:
      return plantTextures.bell12;
    case 13:
      return plantTextures.bell13;
    case 14:
      return plantTextures.bell14;
    case 15:
      return plantTextures.bell15;
    case 16:
      return plantTextures.bell16;
    case 17:
      return plantTextures.bell17;
    case 18:
      return plantTextures.bell18;
    case 19:
      return plantTextures.bell19;
    case 20:
      return plantTextures.bell20;
    case 21:
      return plantTextures.bell21;
    case 22:
      return plantTextures.bell22;
    case 23:
      return plantTextures.bell23;
    case 24:
      return plantTextures.bell24;
  }
};

const getSproutTextureByGrowthStage = (
  growthStage: number,
  plantTextures: AssetsType
) => {
  switch (growthStage) {
    case 0:
      return plantTextures.sprout0;
    case 1:
      return plantTextures.sprout1;
    case 2:
      return plantTextures.sprout2;
    case 3:
      return plantTextures.sprout3;
    case 4:
      return plantTextures.sprout4;
    case 5:
      return plantTextures.sprout5;
    case 6:
      return plantTextures.sprout6;
    case 7:
      return plantTextures.sprout7;
    case 8:
      return plantTextures.sprout8;
    case 9:
      return plantTextures.sprout9;
    case 10:
      return plantTextures.sprout10;
    case 11:
      return plantTextures.sprout11;
    case 12:
      return plantTextures.sprout12;
    case 13:
      return plantTextures.sprout13;
    case 14:
      return plantTextures.sprout14;
    case 15:
      return plantTextures.sprout15;
    case 16:
      return plantTextures.sprout16;
    case 17:
      return plantTextures.sprout17;
    case 18:
      return plantTextures.sprout18;
    case 19:
      return plantTextures.sprout19;
    case 20:
      return plantTextures.sprout20;
    case 21:
      return plantTextures.sprout21;
    case 22:
      return plantTextures.sprout22;
    case 23:
      return plantTextures.sprout23;
    case 24:
      return plantTextures.sprout24;
  }
};

const getSalviaTextureByGrowthStage = (
  growthStage: number,
  plantTextures: AssetsType
) => {
  switch (growthStage) {
    case 0:
      return plantTextures.salvia0;
    case 1:
      return plantTextures.salvia1;
    case 2:
      return plantTextures.salvia2;
    case 3:
      return plantTextures.salvia3;
    case 4:
      return plantTextures.salvia4;
    case 5:
      return plantTextures.salvia5;
    case 6:
      return plantTextures.salvia6;
    case 7:
      return plantTextures.salvia7;
    case 8:
      return plantTextures.salvia8;
    case 9:
      return plantTextures.salvia9;
    case 10:
      return plantTextures.salvia10;
    case 11:
      return plantTextures.salvia11;
    case 12:
      return plantTextures.salvia12;
    case 13:
      return plantTextures.salvia13;
    case 14:
      return plantTextures.salvia14;
    case 15:
      return plantTextures.salvia15;
    case 16:
      return plantTextures.salvia16;
    case 17:
      return plantTextures.salvia17;
    case 18:
      return plantTextures.salvia18;
    case 19:
      return plantTextures.salvia19;
    case 20:
      return plantTextures.salvia20;
    case 21:
      return plantTextures.salvia21;
    case 22:
      return plantTextures.salvia22;
    case 23:
      return plantTextures.salvia23;
    case 24:
      return plantTextures.salvia24;
  }
};

const getPlantTexture = (
  plantType: PlantType,
  plantTextures: AssetsType,
  growthStage: number
) => {
  switch (plantType) {
    case PlantType.Bell:
      return getBellTextureByGrowthStage(growthStage, plantTextures);
    case PlantType.Sprout:
      return getSproutTextureByGrowthStage(growthStage, plantTextures);
    case PlantType.Salvia:
      return getSalviaTextureByGrowthStage(growthStage, plantTextures);
    default:
      return null;
  }
};

export const Plant = ({
  plantType,
  position,
  cellIndex,
  growthStage,
}: PlantProps) => {
  const plantTextures = useAssets() as AssetsType;

  const texture = getPlantTexture(plantType, plantTextures, growthStage);

  return (
    <mesh position={[position[0], position[1], 0]}>
      <planeGeometry args={[1, 1]} />
      <meshBasicMaterial attach="material" map={texture} transparent />
    </mesh>
  );
};
