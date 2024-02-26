const gardenMaxX = 7;
const gardenMaxY = 7.5;
const minGardenX = -gardenMaxX;
const minGardenY = -gardenMaxY;
export const getGardenPositionByCell = (cellIndex: number) => {
  const gridSize = 15;
  const minX = -7;
  const minY = -7.5;
  const x = minX + (cellIndex % gridSize) * ((7 - minX) / (gridSize - 1));
  const y =
    minY + Math.floor(cellIndex / gridSize) * ((7.5 - minY) / (gridSize - 1));
  return [x, y];
};
