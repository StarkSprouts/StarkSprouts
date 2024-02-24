

export const getGardenTile = (
    { x, y, gridSize }: 
    { x: number, y: number, gridSize: number }
) => {

    const maxX = gridSize / 2 - 1;
    const maxY = gridSize / 2 - 1;
    const minX = -gridSize / 2;
    const minY = -gridSize / 2;

    // top left corner 
    if (x === minX && y === minY) return gardenTiles.sand.topLeftCorner;

    // top right corner
    if (x === maxX && y === minY) return gardenTiles.sand.topRightCorner;

    // bottom left corner
    if (x === minX && y === maxY) return gardenTiles.sand.bottomLeftCorner;

    // bottom right corner
    if (x === maxX && y === maxY) return gardenTiles.sand.bottomRightCorner;

    // top row
    if (y === minY) return gardenTiles.sand.topRow;

    // bottom row
    if (y === maxY) return gardenTiles.sand.bottomRow;

    // left column
    if (x === minX) return gardenTiles.sand.leftColumn;

    // right column
    if (x === maxX) return gardenTiles.sand.rightColumn;

    // randomly choose center tile 
    const random = Math.random();
    if (random < 0.33) return gardenTiles.sand.center1;
    if (random < 0.66) return gardenTiles.sand.center2;
    return gardenTiles.sand.center3;
}


export const gardenTiles = {
    grass: {
        0: "/TileSet/Grass/Grass_00.png", 
        1: "/TileSet/Grass/Grass_01.png",
        2: "/TileSet/Grass/Grass_02.png", 
        3: "/TileSet/Grass/Grass_03.png",
        4: "/TileSet/Grass/Grass_04.png",
        5: "/TileSet/Grass/Grass_05.png",
        6: "/TileSet/Grass/Grass_06.png",
        7: "/TileSet/Grass/Grass_07.png",
        8: "/TileSet/Grass/Grass_08.png",
        9: "/TileSet/Grass/Grass_09.png",
        10: "/TileSet/Grass/Grass_10.png",
        11: "/TileSet/Grass/Grass_11.png",
        12: "/TileSet/Grass/Grass_12.png",
        13: "/TileSet/Grass/Grass_13.png",
        14: "/TileSet/Grass/Grass_14.png",
        15: "/TileSet/Grass/Grass_15.png",
        16: "/TileSet/Grass/Grass_16.png",
        17: "/TileSet/Grass/Grass_17.png",
        18: "/TileSet/Grass/Grass_18.png",
        19: "/TileSet/Grass/Grass_19.png",
        20: "/TileSet/Grass/Grass_20.png",
    },
    sand: {
        topLeftCorner: "/TileSet/Sand/Sand_00.png",
        topRow: "/TileSet/Sand/Sand_01.png",
        topRightCorner: "/TileSet/Sand/Sand_02.png",
        leftColumn: "/TileSet/Sand/Sand_06.png",
        rightColumn: "/TileSet/Sand/Sand_08.png",
        center1: "/TileSet/Sand/Sand_07.png",
        center2: "/TileSet/Sand/Sand_15.png",
        center3: "/TileSet/Sand/Sand_16.png",
        bottomRow: "/TileSet/Sand/Sand_13.png",
        bottomLeftCorner: "/TileSet/Sand/Sand_12.png",
        bottomRightCorner: "/TileSet/Sand/Sand_14.png",
    }
}

