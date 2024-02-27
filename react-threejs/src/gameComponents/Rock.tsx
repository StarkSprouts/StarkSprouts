import { useDojo } from "@/dojo/useDojo";
import { useAssets } from "./AssetLoader";
import { useState } from "react";

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
    console.log("Rock clicked!");
    const txHash = await removeRock(account, cellIndex);
    console.log("Rock removed txHash: ", txHash);
  };

  const handleRockHover = () => {
    console.log("Rock hovered!");
    setIsHovered(true);
  };

  const handleRockUnhover = () => {
    console.log("Rock unhovered!");
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
      {isHovered && (
        <meshBasicMaterial
          attach="material"
          map={rock}
          transparent
          opacity={0.5}
        />
      )}
      {!isHovered && (
        <meshBasicMaterial attach="material" map={rock} transparent />
      )}
    </mesh>
  );
};
