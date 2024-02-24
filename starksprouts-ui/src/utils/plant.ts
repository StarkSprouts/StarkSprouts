
export function getPlantImage(plantType: string, growthStage: number): string {

  const paddedStage = growthStage.toString().padStart(2, "0");

  return `/plants/${plantType}_${growthStage <= 9 ? paddedStage : growthStage}.png`;

}
