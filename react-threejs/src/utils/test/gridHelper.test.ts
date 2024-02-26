import { getGardenPositionByCell } from "../gridHelper";

describe("getGardenPositionByCell", () => {
  it("should return the correct garden position for a the top left cell index", () => {
    const topLeftCellIndex = 0;
    expect(getGardenPositionByCell(topLeftCellIndex).toString()).toEqual(
      [-7, 7.5].toString()
    );
  });
  it("should return the correct garden position for a the top right cell index", () => {
    const topRightCellIndex = 14;
    expect(getGardenPositionByCell(topRightCellIndex).toString()).toEqual(
      [7, 7.5].toString()
    );
  });
  it("should return the correct garden position for a the bottom left cell index", () => {
    const bottomLeftCellIndex = 210;
    expect(getGardenPositionByCell(bottomLeftCellIndex).toString()).toEqual(
      [-7, -7.5].toString()
    );
  });
  it("should return the correct garden position for a the bottom right cell index", () => {
    const bottomRightCellIndex = 224;
    expect(getGardenPositionByCell(bottomRightCellIndex).toString()).toEqual(
      [7, -7.5].toString()
    );
  });
});
