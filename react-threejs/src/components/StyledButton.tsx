type ButtonProps = {
  onPress?: () => void;
  label?: string;
  children?: React.ReactNode;
};

export const StyledButton = (props: ButtonProps) => {
  return (
    <button
      onClick={props.onPress}
      className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
    >
      {props.label || props.children}
    </button>
  );
};
