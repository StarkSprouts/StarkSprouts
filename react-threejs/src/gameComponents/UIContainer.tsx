import { useDojo } from "../dojo/useDojo";
import { StyledButton } from "@/components/StyledButton";
import { useComponentValue } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";

export const UIContainer = () => {
  return (
    <div className="flex space-x-3 justify-between p-2 flex-wrap">
      <StyledButton onPress={() => console.log("garden initialized")}>
        Initialize Garden
      </StyledButton>
      <StyledButton onPress={() => console.log("garden refreshed")}>
        Refresh Garden
      </StyledButton>
      <StyledButton onPress={() => console.log("rock removed")}>
        Remove Rock
      </StyledButton>
      <StyledButton onPress={() => console.log("seed planted")}>
        Plant Seed
      </StyledButton>
      <StyledButton onPress={() => console.log("plant watered")}>
        Water Plant
      </StyledButton>
      <StyledButton onPress={() => console.log("dead plant removed")}>
        Remove Dead Plant
      </StyledButton>
      <StyledButton onPress={() => console.log("plant harvested")}>
        Harvest Plant
      </StyledButton>
      <div className="h-12 w-48 bg-white flex justify-center items-center border-2"></div>
    </div>
  );
};
