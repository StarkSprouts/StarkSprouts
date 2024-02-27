import { useState } from "react";
import { useDojo } from "../dojo/useDojo";
import { StyledButton } from "@/components/StyledButton";
import Modal from "@/components/Modal";
import { useComponentValue } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";
import { getEntityIdFromKeys } from "@dojoengine/utils";

export const UIContainer = () => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const openModal = () => setIsModalOpen(true);
  const closeModal = () => setIsModalOpen(false);
  return (
    <>
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
      </div>

      <div className="App">
        <button
          onClick={openModal}
          className="p-2 bg-blue-500 text-white rounded"
        >
          Open Modal
        </button>

        <Modal isOpen={isModalOpen} onClose={closeModal}>
          <h2 className="text-lg font-bold mb-4">Modal Title</h2>
          <p>
            This is a modal. You can put any content here, like forms or
            additional information.
          </p>
        </Modal>
      </div>
    </>
  );
};
