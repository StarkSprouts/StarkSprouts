import React, { useRef, useEffect } from "react";
import * as THREE from "three";

export const GardenScene: React.FC = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (typeof window !== "undefined" && containerRef.current) {
      const handleResize = () => {
        const width = window.innerWidth;
        const height = window.innerHeight;

        camera.aspect = width / height;
        camera.updateProjectionMatrix();

        renderer.setSize(width, height);
      };

      window.addEventListener("resize", handleResize);

      const scene = new THREE.Scene();

      // camera looks top down
      const camera = new THREE.PerspectiveCamera(
        75,
        window.innerWidth / window.innerHeight,
        0.1,
        1000
      );
      camera.position.set(0, 50, 0);
      camera.lookAt(0, 0, 0);

      const renderer = new THREE.WebGLRenderer({ antialias: true });
      renderer.setSize(window.innerWidth, window.innerHeight);

      containerRef.current.appendChild(renderer.domElement);

      // create grid of tiles
      const tileSize = 1;
      const gridSize = 15;
      for (let x = -gridSize / 2; x < gridSize / 2; x++) {
        for (let y = -gridSize / 2; y < gridSize / 2; y++) {
          const geometry = new THREE.PlaneGeometry(tileSize, tileSize);
          const material = new THREE.MeshBasicMaterial({
            color: 0x00ff00,
            side: THREE.DoubleSide,
          });
          const tile = new THREE.Mesh(geometry, material);
          tile.rotation.x = -Math.PI / 2;
          tile.position.set(x * tileSize, 0, y * tileSize);
          scene.add(tile);
        }
      }

      const renderScene = () => {
        requestAnimationFrame(renderScene);
        renderer.render(scene, camera);
      };

      renderScene();

      // Clean up the event listener when the component is unmounted
      return () => {
        window.removeEventListener("resize", handleResize);
      };
    }
  }, []);
  return <div ref={containerRef} />;
};
/*
function GardenTiles() {
  // Define the size of the grid
  const gridSize = 15;
  // Define the size of each tile
  const tileSize = 2;

  // Create an array to hold all the tiles
  let tiles = [];

  for (let x = 0; x < gridSize; x++) {
    for (let y = 0; y < gridSize; y++) {
      const texture = useLoader(TextureLoader, getGardenTile({ x, y }));
      // Calculate the position of each tile
      // Assuming the center of the grid is at (0, 0), adjust positions accordingly
      const positionX = x * tileSize - (gridSize * tileSize) / 2 + tileSize / 2;
      const positionY = y * tileSize - (gridSize * tileSize) / 2 + tileSize / 2;

      // Create a tile at the calculated position
      const tile = (
        <mesh key={`${x}-${y}`} position={[positionX, positionY, 0]}>
          <planeGeometry attach="geometry" args={[tileSize, tileSize]} />
          <meshBasicMaterial attach="material" map={texture} />
        </mesh>
      );

      // Add the tile to the array of tiles
      tiles.push(tile);
    }
  }

  // Return all the tiles as a group
  return <group>{tiles}</group>;
}

function Plants() {
  const plantTexture = useLoader(TextureLoader, "/plants/salvia/salvia_17.png");
  return (
    <mesh position={[1, 1, 0.1]}>
      <planeGeometry attach="geometry" args={[0.5, 0.5]} />
      <meshBasicMaterial attach="material" map={plantTexture} />
    </mesh>
  );
}
*/
