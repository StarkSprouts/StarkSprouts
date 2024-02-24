
export function getPlantImage(plantType: string, growthStage: number): string {

  // create random number between 0 and 13
  const random: number = Math.floor(Math.random() * 24);
  console.log("random", random);

  return plants.salvia[random];
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

const plants = {
  salvia: {
    0: "/plants/salvia/salvia_00.png",
    1: "/plants/salvia/salvia_01.png",
    2: "/plants/salvia/salvia_02.png",
    3: "/plants/salvia/salvia_03.png",
    4: "/plants/salvia/salvia_04.png",
    5: "/plants/salvia/salvia_05.png",
    6: "/plants/salvia/salvia_06.png",
    7: "/plants/salvia/salvia_07.png",
    8: "/plants/salvia/salvia_08.png",
    9: "/plants/salvia/salvia_09.png",
    10: "/plants/salvia/salvia_10.png",
    11: "/plants/salvia/salvia_11.png",
    12: "/plants/salvia/salvia_12.png",
    13: "/plants/salvia/salvia_13.png",
    14: "/plants/salvia/salvia_14.png",
    15: "/plants/salvia/salvia_15.png",
    16: "/plants/salvia/salvia_16.png",
    17: "/plants/salvia/salvia_17.png",
    18: "/plants/salvia/salvia_18.png",
    19: "/plants/salvia/salvia_19.png",
    20: "/plants/salvia/salvia_20.png",
    21: "/plants/salvia/salvia_21.png",
    22: "/plants/salvia/salvia_22.png",
    23: "/plants/salvia/salvia_23.png",
    24: "/plants/salvia/salvia_24.png",
  } as { [key: number]: string},
}