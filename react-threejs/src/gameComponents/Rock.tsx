import { useDojo } from "@/dojo/useDojo";
import { useAssets } from "./AssetLoader";
import { useState } from "react";
import type { AssetsType } from "./AssetLoader";

export type RockProps = {
  position: [number, number];
  cellIndex: number;
};

export const Rock = ({ position, cellIndex }: RockProps) => {
  const {
    account: { account },
    setup: {
      systemCalls: { removeRock },
    },
  } = useDojo();
  const [isHovered, setIsHovered] = useState(false);

  const { rock } = useAssets() as AssetsType;

  const handleRockClicked = async () => {
    const txHash = await removeRock(account, cellIndex);
  };

  const handleRockHover = () => {
    setIsHovered(true);
  };

  const handleRockUnhover = () => {
    setIsHovered(false);
  };

  return (
    <mesh
      position={[position[0], position[1], 0]}
      onClick={handleRockClicked}
      onPointerOver={() => handleRockHover()}
      onPointerOut={() => handleRockUnhover()}
    >
      <planeGeometry args={[1, 1]} />
      {isHovered ? (
        <meshBasicMaterial
          attach="material"
          map={rock}
          transparent
          opacity={0.5}
        />
      ) : (
        <meshBasicMaterial attach="material" map={rock} transparent />
      )}
    </mesh>
  );
};
