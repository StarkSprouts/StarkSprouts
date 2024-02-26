import React, { useRef, useEffect } from "react";
import { Canvas, useThree } from "@react-three/fiber";
import { Vector3 } from "three";
import { AssetLoader } from "@/gameComponents/AssetLoader";
import useWindowSize from "@/hooks/useWindowSize";

type GameProps = {
  children: React.ReactNode;
  canvasWidth: number;
  canvasHeight: number;
};

const CameraAdjuster = ({ position }: { position: Vector3 }) => {
  const { camera } = useThree();

  useEffect(() => {
    camera.position.set(position.x, position.y, position.z);
    camera.updateProjectionMatrix();
  }, [camera, position]);

  return null;
};

export const Game = ({ children, canvasWidth, canvasHeight }: GameProps) => {
  return (
    <Canvas
      camera={{
        position: [0, 0, 10],
        fov: 100,
        near: 0.1,
        far: 1000,
      }}
      style={{ width: canvasWidth, height: canvasHeight }}
    >
      <AssetLoader>{children}</AssetLoader>
    </Canvas>
  );
};
