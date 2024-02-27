import { useDojo } from "@/dojo/useDojo";
import { useAssets } from "./AssetLoader";

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

  const { rock } = useAssets() as AssetsType;

  const handleRockClicked = async () => {
    console.log("Rock clicked!");
    const txHash = await removeRock(account, cellIndex);
    console.log("Rock removed txHash: ", txHash);
  };

  return (
    <mesh position={[position[0], position[1], 0]} onClick={handleRockClicked}>
      <planeGeometry args={[1, 1]} />
      <meshBasicMaterial attach="material" map={rock} transparent />
    </mesh>
  );
};
