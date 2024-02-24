
export function getPlantImage(plantType: string, growthStage: number): string {

  const paddedStage = growthStage.toString().padStart(2, "0");

  return `/plants/${plantType}_${growthStage <= 9 ? paddedStage : growthStage}.png`;

}

export function shouldPlacePlant({x, y, gridSize}: {x: number, y: number, gridSize: number}): boolean {
  // dont place plants on the edges
  if (
    x === gridSize / 2 - 1 || 
    x === -gridSize / 2 || 
    y === gridSize / 2 - 1 || 
    y === -gridSize / 2) return false;

  return true
}
