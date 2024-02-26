import { Game } from "@/gameComponents/Game";
import { WorldScene } from "@/scenes/WorldScene";
import useWindowSize from "@/hooks/useWindowSize";

export default function GamePage() {
  const [width, height] = useWindowSize();
  return (
    <div className="flex justify-center items-center">
      <Game canvasWidth={width} canvasHeight={height}>
        <WorldScene />
      </Game>
    </div>
  );
}
