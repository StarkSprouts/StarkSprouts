import { Tile } from "@/gameComponents/Tile";
import { TileType } from "@/gameComponents/Tile";

const tileMap = `
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGG1TTTTTTTTTTTTTTT2GGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGLPPPPPPPPPPPPPPPRGGGGGGGGGGGGGG
GGGGGGGGGGGGGGG3BBBBBBBBBBBBBBB4GGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG
`;
export const WorldScene = () => {
  // G is grass, P is a garden plot

  const renderTileMap = () => {
    const rows = tileMap.trim().split("\n").reverse();

    console.log(rows);
    const mapWidth = rows[0].length;
    console.log;
    const mapHeight = rows.length;
    const xOffset = -mapWidth / 2;
    const yOffset = -mapHeight / 2;

    console.log(`MAP WIDTH: ${mapWidth}`);
    console.log(`MAP HEIGHT: ${mapHeight}`);
    console.log(`X OFFSET: ${xOffset}`);
    console.log(`Y OFFSET: ${yOffset}`);

    return rows.map((row, y) => {
      return row.split("").map((type, x) => {
        const adjustedX = x - mapWidth / 2;
        const adjustedY = y - mapHeight / 2;
        return (
          <Tile
            key={`${x},${y}`}
            type={type as TileType}
            position={[adjustedX, adjustedY]}
          />
        );
      });
    });
  };

  return <>{renderTileMap()}</>;
};
